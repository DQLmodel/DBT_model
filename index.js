const core = require("@actions/core");
const github = require("@actions/github");
const axios = require("axios");
const fs = require("fs");
const path = require("path");
const yaml = require("js-yaml");

// Import utilities with safe fallbacks
const { 
  extractColumnsFromSQL = () => [], 
  getFileContent = () => null, 
  extractColumnsFromYML = () => [] 
} = require("./sql-parser") || {};

// Get inputs with defaults
const clientId = core.getInput("api_client_id") || "";
const clientSecret = core.getInput("api_client_secret") || "";
const changedFilesList = core.getInput("changed_files_list") || "";
const githubToken = core.getInput("GITHUB_TOKEN") || "";
const dqlabs_base_url = core.getInput("dqlabs_base_url") || "";
const dqlabs_createlink_url = core.getInput("dqlabs_createlink_url") || "";

// Safe array processing utility
const safeArray = (maybeArray) => Array.isArray(maybeArray) ? maybeArray : [];

const getChangedFiles = async () => {
  try {
    if (changedFilesList && typeof changedFilesList === "string") {
      return changedFilesList
        .split(",")
        .map(f => typeof f === "string" ? f.trim() : "")
        .filter(f => f && f.length > 0);
    }

    const eventPath = process.env.GITHUB_EVENT_PATH;
    if (!eventPath) return [];

    const eventData = JSON.parse(fs.readFileSync(eventPath, "utf8"));
    const changedFiles = new Set();

    const commits = safeArray(eventData.commits);
    commits.forEach(commit => {
      if (!commit) return;
      const files = [
        ...safeArray(commit.added),
        ...safeArray(commit.modified),
        ...safeArray(commit.removed)
      ];
      files.filter(Boolean).forEach(file => changedFiles.add(file));
    });

    return Array.from(changedFiles);
  } catch (error) {
    core.error(`[getChangedFiles] Error: ${error.message}`);
    return [];
  }
};

const getTasks = async () => {
  try {
    const taskUrl = `${dqlabs_base_url}/api/pipeline/task/`;
    const payload = {
      chartType: 0,
      search: {},
      page: 0,
      pageLimit: 100,
      sortBy: "name",
      orderBy: "asc",
      date_filter: { days: "All", selected: "All" },
      chart_filter: {},
      is_chart: true,
    };

    const response = await axios.post(taskUrl, payload, {
      headers: {
        "Content-Type": "application/json",
        "client-id": clientId,
        "client-secret": clientSecret,
      }
    });

    return response?.data?.response?.data || [];
  } catch (error) {
    core.error(`[getTasks] Error: ${error.message}`);
    return [];
  }
};

const getLineageData = async (asset_id, connection_id, entity) => {
  try {
    const lineageUrl = `${dqlabs_base_url}/api/lineage/entities/linked/`;
    const payload = {
      asset_id,
      connection_id,
      entity,
    };
 
    const response = await axios.post(
      lineageUrl,
      payload,
      {
        headers: {
          "Content-Type": "application/json",
          "client-id": clientId,
          "client-secret": clientSecret,
        },
      }
    );
 
    return safeArray(response?.data?.response?.data);
  } catch (error) {
    core.error(`[getLineageData] Error for ${entity}: ${error.message}`);
    return [];
  }
};

const run = async () => {
  try {
    // Initialize summary with basic info
    let summary = "## Impact Analysis Report\n\n";
    
    // Get changed files safely
    const changedFiles = safeArray(await getChangedFiles());
    core.info(`Found ${changedFiles.length} changed files`);
    
    // Process changed SQL models
    const changedModels = changedFiles
      .filter(file => file && typeof file === "string" && file.endsWith(".sql"))
      .map(file => path.basename(file, path.extname(file)))
      .filter(Boolean);

    // Get tasks safely
    const tasks = await getTasks();
    
    // Match tasks with changed models
    const matchedTasks = tasks
      .filter(task => task?.connection_type === "dbt")
      .filter(task => changedModels.includes(task?.name))
      .map(task => ({
        ...task,
        entity: task?.task_id || ""
      }));

    // Process lineage data
    const Everydata = {
      direct: [],
      indirect: []
    };

    for (const task of matchedTasks) {
      const lineageTables = await getLineageData(
        task.asset_id,
        task.connection_id,
        task.entity
      );

      const lineageData = lineageTables
        .filter(table => table?.flow === "downstream")
        .filter(Boolean);

      Everydata.direct.push(...lineageData);
    }

    // Process indirect impacts
    const processIndirectImpacts = async (items, x) => {
      for (const item of safeArray(items)) {
        if (x === "second" ) {
          Everydata.indirect.push(item);
        }
        const lineageTables = await getLineageData(
          item.asset_id,
          item.connection_id,
          item.entity
        );
        
        if (lineageTables && lineageTables.length > 0) {
          const downstream = lineageTables
            .filter(table => table?.flow === "downstream")
            .filter(Boolean);
          await processIndirectImpacts(downstream, "second");
        }
      }
    };

    await processIndirectImpacts(Everydata.direct, "first");

    const uniqueKey = (item) => `${item?.name}-${item?.connection_id}-${item?.asset_name}`;

    // Create a Set of keys from direct items
    const directKeys = new Set(Everydata.direct.map(uniqueKey));

    // Filter indirect items to remove those already in direct
    Everydata.indirect = Everydata.indirect.filter(
      item => !directKeys.has(uniqueKey(item))
    );

    // Optional: Remove duplicates within direct and indirect themselves
    const dedup = (arr) => {
      const seen = new Set();
      return arr.filter(item => {
        const key = uniqueKey(item);
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
      });
    };

    Everydata.direct = dedup(Everydata.direct);
    Everydata.indirect = dedup(Everydata.indirect);

    const constructItemUrl = (item, baseUrl) => {
      if (!item || !baseUrl) return "#";
      
      try {
        const url = new URL(baseUrl);
        
        // Handle pipeline items
        if (item.asset_group === "pipeline") {
          if (item.is_transform) {
            url.pathname = `/observe/pipeline/transformation/${item.redirect_id}/run`;
          } else {
            url.pathname = `/observe/pipeline/task/${item.redirect_id}/run`;
          }
          return url.toString();
        }
        
        // Handle data items
        if (item.asset_group === "data") {
          url.pathname = `/observe/data/${item.redirect_id}/measures`;
          return url.toString();
        }
        
        // Default case
        return "#";
      } catch (error) {
        core.error(`Error constructing URL for ${item.name}: ${error.message}`);
        return "#";
      }
    };

    // Build summary
    // Helper function to create collapsible sections when needed
    const buildImpactSection = (directItems, indirectItems) => {
      const totalImpacts = directItems.length + indirectItems.length;
      const shouldCollapse = totalImpacts < 20;
      
      let content = `## Directly Impacted (${directItems.length})\n`;
      directItems.forEach(model => {
        const url = constructItemUrl(model, dqlabs_createlink_url);
        content += `- [${model?.name || 'Unknown'}](${url})\n`;
      });

      content += `\n## Indirectly Impacted (${indirectItems.length})\n`;
      indirectItems.forEach(model => {
        const url = constructItemUrl(model, dqlabs_createlink_url);
        content += `- [${model?.name || 'Unknown'}](${url})\n`;
      });

      return shouldCollapse
        ? `<details>\n<summary><b>Impact Analysis (${totalImpacts} items) - Click to expand</b></summary>\n\n${content}\n</details>`
        : content;
    };

    // In your summary generation:
    summary += buildImpactSection(Everydata.direct, Everydata.indirect);
    // Process column changes
    const processColumnChanges = async (extension, extractor) => {
      const changes = [];
      let added = [];
      let removed = [];

      for (const file of changedFiles.filter(f => f && f.endsWith(extension))) {
        try {
          const baseSha = process.env.GITHUB_BASE_SHA || github.context.payload.pull_request?.base?.sha;
          const headSha = process.env.GITHUB_HEAD_SHA || github.context.payload.pull_request?.head?.sha;
          
          const baseContent = baseSha ? await getFileContent(baseSha, file) : null;
          const headContent = await getFileContent(headSha, file);
          if (!headContent) continue;

          const baseCols = safeArray(baseContent ? extractor(baseContent) : []);
          const headCols = safeArray(extractor(headContent));

          const addedCols = headCols.filter(col => !baseCols.includes(col));
          const removedCols = baseCols.filter(col => !headCols.includes(col));

          if (addedCols.length > 0 || removedCols.length > 0) {
            changes.push({ file, added: addedCols, removed: removedCols });
            added.push(...addedCols);
            removed.push(...removedCols);
          }
        } catch (error) {
          core.error(`Error processing ${file}: ${error.message}`);
        }
      }

      return { changes, added, removed };
    };

    // Process SQL changes
    const { added: sqlAdded, removed: sqlRemoved } = await processColumnChanges(".sql", extractColumnsFromSQL);
    summary += `\n### SQL Column Changes\n`;
    summary += `Added: ${sqlAdded.length} columns\n`;
    summary += `Removed: ${sqlRemoved.length} columns\n`;

    // Process YML changes
    const { added: ymlAdded, removed: ymlRemoved } = await processColumnChanges(".yml", extractColumnsFromYML);
    summary += `\n### YML Column Changes\n`;
    summary += `Added: ${ymlAdded.length} columns\n`;
    summary += `Removed: ${ymlRemoved.length} columns\n`;

    // Post comment
    if (github.context.payload.pull_request) {
      try {
        const octokit = github.getOctokit(githubToken);
        await octokit.rest.issues.createComment({
          owner: github.context.repo.owner,
          repo: github.context.repo.repo,
          issue_number: github.context.payload.pull_request.number,
          body: summary,
        });
      } catch (error) {
        core.error(`Failed to create comment: ${error.message}`);
      }
    }

    // Output results
    await core.summary
      .addRaw(summary)
      .write();
      
    core.setOutput("impact_markdown", summary);
  } catch (error) {
    core.setFailed(`[MAIN] Unhandled error: ${error.message}`);
    core.error(error.stack);
  }
};

// Execute
run().catch(error => {
  core.setFailed(`[UNCAUGHT] Critical failure: ${error.message}`);
});
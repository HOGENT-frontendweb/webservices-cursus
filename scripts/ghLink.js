const MATCHER = /l\>\s+(ws|fe)\s+(start|oplossing)\s+([0-9a-fA-F]{7})\s+(.+)/gm;

const githubLinks = new Map([
  ['ws', 'https://github.com/HOGENT-Web/webservices-budget.git'],
  ['fe', 'https://github.com/HOGENT-Web/frontendweb-budget.git']
]);

const folderNames = new Map([
  ['ws', 'webservices-budget'],
  ['fe', 'frontendweb-budget']
]);

function getGitHubLink(course) {
  if (!githubLinks.has(course)) {
    throw new Error(`Invalid course: ${course}`);
  }
  return githubLinks.get(course);
}

function getFolderName(course) {
  if (!folderNames.has(course)) {
    throw new Error(`Invalid course: ${course}`);
  }
  return folderNames.get(course);
}

function getHeader(type) {
  if (type === 'start') {
    return 'Startpunt voorbeeldapplicatie';
  }
  if (type === 'oplossing') {
    return 'Oplossing voorbeeldapplicatie';
  }
  throw new Error(`Invalid type: ${type}`);
}

function makeOutput({ course, type, commit, branchname }) {
  return `
## ${getHeader(type)}

\`\`\`terminal
git clone ${getGitHubLink(course)}
cd ${getFolderName(course)}
git checkout -b ${branchname} ${commit}
yarn install
yarn start
\`\`\`
  `.trim();
}

(function () {
  function gh_links(hook) {
    hook.beforeEach(function (md) {
      return md.replace(MATCHER, (_, course, type, commit, branchname) => {
        return makeOutput({
          course,
          type,
          commit,
          branchname,
        });
      });
    });
  }

  window.$docsify.plugins = [].concat(gh_links, $docsify.plugins)
}());

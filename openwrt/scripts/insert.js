const fs = require('fs');

const newCode = `		// 添加新的行，文本居中，颜色为绿色
        var newRow = E('tr', { 'class': 'tr' });
        var newCell = E('td', { 'class': 'td center', 'colspan': '2', 'style': 'color: green;' },
            _('永远爱世界上最可爱的小满!')
        );
        newRow.appendChild(newCell);
        table.appendChild(newRow); // 将新行添加到表格
`;

function modifyFile(filePath) {
  try {
    const fileContent = fs.readFileSync(filePath, 'utf-8');
    const lines = fileContent.split('\n');
    const returnTableIndex = lines.findIndex(line => line.trim() === 'return table;');

    if (returnTableIndex === -1) {
      console.error(`Could not find "return table;" in ${filePath}`);
      return; // Exit early if "return table;" is not found
    } else {
      lines.splice(returnTableIndex, 0, newCode);
      const updatedFileContent = lines.join('\n');
      fs.writeFileSync(filePath, updatedFileContent);
      console.log(`Code inserted successfully into ${filePath}!`);
    }
  } catch (err) {
    console.error(`Error modifying ${filePath}:`, err);
  }
}


const filePaths = [
  './feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js',
  './package/system/autocore/files/generic/10_system.js'
];

filePaths.forEach(filePath => modifyFile(filePath));

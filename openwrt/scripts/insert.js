const fs = require('fs');

const filePath = './feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js';
const newCode = `		// 添加新的行，文本居中，颜色为绿色
        var newRow = E('tr', { 'class': 'tr' });
        var newCell = E('td', { 'class': 'td center', 'colspan': '2', 'style': 'color: green;' },
            _('永远爱世界上最可爱的小满!')
        );
        newRow.appendChild(newCell);
        table.appendChild(newRow); // 将新行添加到表格
`;

try {
  const fileContent = fs.readFileSync(filePath, 'utf-8');
  const lines = fileContent.split('\n');
  const returnTableIndex = lines.findIndex(line => line.trim() === 'return table;');

  if (returnTableIndex === -1) {
    console.error('Could not find "return table;"');
  } else {
    lines.splice(returnTableIndex, 0, newCode); // 去除 .trim()
    const updatedFileContent = lines.join('\n');
    fs.writeFileSync(filePath, updatedFileContent);
    console.log('Code inserted successfully!');
  }
} catch (err) {
  console.error('Error:', err);
}

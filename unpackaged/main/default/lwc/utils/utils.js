export function exportCSVFile(headers, rows, fileName) {
    const now = new Date();
    const date = now.toLocaleDateString();
    date.replace('/', '_');

    fileName += '__' + date + '.csv';

    const processRows = JSON.stringify(rows);
    const csvFile = createCSV(processRows, headers);
    const blob = new Blob([csvFile]);

    /*if (window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveBlob(blob, fileName);
    } else if (navigator.userAgent.match(/iPhone|iPad|iPod|Android/i)) {
        const dataUrl = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = dataUrl;
        link.target="_blank";
        link.download = fileName;
        link.click();
        window.URL.revokeObjectURL(dataUrl);
    } else {*/
        const downloadLink = document.createElement('a');
        const url = URL.createObjectURL(blob);
        downloadLink.href = url;
        downloadLink.download = fileName;
        downloadLink.style.visibility = 'hidden';
        document.body.appendChild(downloadLink);
        downloadLink.click();
        
        setTimeout(() => {
            document.body.removeChild(downloadLink);
        }, 100);
    //}
}

function createCSV(contents, headers) {
    const headerKeys = Object.keys(headers);
    const headerValues = Object.values(headers);
    let csv = '';

    csv += headerValues.join(',');
    csv += '\r\n';

    contents = contents.replaceAll('\\n', ' | ');
    contents = contents.replaceAll('\n', ' | ');
    contents = contents.replaceAll('\r', ' | ');
    contents = contents.replaceAll(', ', ' ');
    contents = contents.replaceAll('    ', ' ');
    const data = typeof contents !== 'object' ? JSON.parse(contents) : contents;

    data.forEach(element => {
        let row = '';
        headerKeys.forEach(key => {
            if (row != '') { row += ','; }
            let rowValues = element[key];
            row += rowValues;
            row = row.replace(undefined, '');
        })
        csv += row + '\r\n';
    });

    return csv;
}
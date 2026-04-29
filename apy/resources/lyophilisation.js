// Initialize Handsontable with Temperature and Power columns
let hot; // Global reference to the Handsontable instance
let hotResults; // Global reference for results table

document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('handson-container');
    
    hot = new Handsontable(container, {
        data: [
        ],
        columns: [
            {
                data: 'temperature',
                title: 'Temperature (°C)',
                type: 'numeric',
            },
            {
                data: 'power',
                title: 'Power (W)',
                type: 'numeric',
            }
        ],
        rowHeaders: true,
        colHeaders: true,
        height: 'auto',
        minSpareRows: 5,
        stretchH: 'all',
        dropdownMenu: ['copy', 'cut', 'paste'],
        contextMenu: ['copy', 'cut', 'paste'],
        copyPaste: {
            pasteMode: 'overwrite'
        },
        afterPaste: function(changes, source) {
            // Auto-adjust rows after pasting
            const lastRow = Math.max(...changes.map(change => change[0]));
            if (lastRow > this.countRows() - 3) {
                this.alter('insert_row', this.countRows(), 10);
            }
        },
        licenseKey: 'non-commercial-and-evaluation'
    });

    // Add Process button event listener
    document.getElementById('processBtn').addEventListener('click', processData);
});

async function processData() {
    try {
        // Get data from Handsontable
        const tableData = hot.getData();
        
        // Filter out empty rows
        const validData = tableData.filter(row => row[0] !== null && row[0] !== undefined && row[1] !== null && row[1] !== undefined);
        
        // if (validData.length === 0) {
        //     alert('Please enter at least one row of data');
        //     return;
        // }

        // Convert to array format for the backend
        const payload = {
            data: validData
        };

        // Send POST request to /lyophilisation/array endpoint
        const response = await fetch('/lyophilisation/array', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        displayResult(result);

    } catch (error) {
        console.error('Error processing data:', error);
        displayResult({
            status: 'error',
            message: error.message
        });
    }
}

function displayResult(result) {
    // const statusDiv = document.getElementById('result-status');
    const resultContainer = document.getElementById('result-container');
    
    if (result.status === 'success') {
        // statusDiv.className = 'result-status success';
        // statusDiv.innerHTML = '<strong>✓ Success!</strong> Data processed successfully.';
        // statusDiv.style.display = 'block';
        
        // Prepare data for the results table
        const resultData = result.received_data;
        
        // Determine columns dynamically from the data
        let columns = [];
        if (Array.isArray(resultData) && resultData.length > 0) {
            if (Array.isArray(resultData[0])) {
                // If data is an array of arrays, use generic column names
                const firstRow = resultData[0];
                columns = firstRow.map((_, index) => ({
                    title: `Column ${index + 1}`,
                    type: 'numeric'
                }));
            } else if (typeof resultData[0] === 'object') {
                // If data is an array of objects, use the keys as column titles
                columns = Object.keys(resultData[0]).map(key => ({
                    data: key,
                    title: key,
                    type: 'numeric'
                }));
            }
        }
        
        // Create or update results table
        if (hotResults) {
            hotResults.destroy();
        }
        
        hotResults = new Handsontable(resultContainer, {
            data: resultData,
            columns: columns,
            rowHeaders: true,
            colHeaders: true,
            height: 'auto',
            stretchH: 'all',
            readOnly: true,
            licenseKey: 'non-commercial-and-evaluation'
        });
        
    } else {
        // statusDiv.className = 'result-status error';
        // statusDiv.innerHTML = `<strong>✗ Error:</strong> ${result.message || 'Unknown error occurred'}`;
        // statusDiv.style.display = 'block';
        resultContainer.innerHTML = '';
        if (hotResults) {
            hotResults.destroy();
        }
    }
}

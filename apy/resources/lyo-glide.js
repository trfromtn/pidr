// Initialize Glide Data Grid
let grid;
let gridData = [];
let useSimpleTable = false;

const COLUMN_HEADERS = [
    'Durée totale de congélation (s)',
    'Volume produit dans le vial (m3)',
    'T étagère(K)',
    'Pression chambre (Pa)',
    'Durée post séchage primaire (s)',
    'T étagère secondaire (K)',
    'Humidité résiduelle cible (kg/kg)'
];

// Mapping of column names to French titles for results display
const RESULT_COLUMN_TITLES = {
    'humidite_residuelle': 'Humidité résiduelle',
    'humidité_résiduelle': 'Humidité résiduelle',
    'humidite residuelle': 'Humidité résiduelle',
    'humidité residuelle': 'Humidité résiduelle',
    'masse_glace': 'Masse de glace (kg)',
    'masse_glace_kg': 'Masse de glace (kg)',
    'masse glace': 'Masse de glace (kg)',
    'masse glace kg': 'Masse de glace (kg)'
};

function getColumnTitle(key) {
    // Check if there's a direct mapping for this key
    if (RESULT_COLUMN_TITLES[key]) {
        return RESULT_COLUMN_TITLES[key];
    }
    // Try lowercase version
    const lowerKey = key.toLowerCase();
    if (RESULT_COLUMN_TITLES[lowerKey]) {
        return RESULT_COLUMN_TITLES[lowerKey];
    }
    // Return the original key if no mapping found
    return key;
}

function initializeGrid(data = []) {
    const container = document.getElementById('gridContainer');
    
    // Default empty grid
    if (data.length === 0) {
        data = [
            ['', '', '', '', '', '', ''],
            ['', '', '', '', '', '', ''],
            ['', '', '', '', '', '', '']
        ];
    }
    
    gridData = JSON.parse(JSON.stringify(data)); // Deep copy
    
    // Get dimensions
    const numRows = data.length;
    const numCols = data.length > 0 ? data[0].length : 3;
    
    // Clear container
    container.innerHTML = '';

    useSimpleTable = true;
    initializeSimpleTable(data);

    
}


function initializeSimpleTable(data) {
    const container = document.getElementById('gridContainer');
    const numRows = data.length;
    const numCols = COLUMN_HEADERS.length;
    
    let html = '<table class="input-table">';
    
    // Header row
    html += '<thead>';
    html += '<tr>';
    for (let c = 0; c < numCols; c++) {
        html += `<th>${COLUMN_HEADERS[c]}</th>`;
    }
    html += '</tr>';
    html += '</thead>';
    
    // Data rows
    html += '<tbody>';
    for (let r = 0; r < numRows; r++) {
        html += '<tr>';
        for (let c = 0; c < numCols; c++) {
            const value = gridData[r]?.[c] || '';
            const cellId = `cell-${r}-${c}`;
            html += `<td><input 
                            type="text" 
                            id="${cellId}"
                            value="${value.replace(/"/g, '&quot;')}"
                            onchange="updateGridData(${r}, ${c}, this.value)"
                        /></td>`;
        }
        html += '</tr>';
    }
    html += '</tbody>';
    html += '</table>';
    
    container.innerHTML = html;
    console.log('Simple table initialized successfully');
}

function updateGridData(row, col, value) {
    if (!gridData[row]) {
        gridData[row] = [];
    }
    gridData[row][col] = value;
}

function parseAndLoadData(text) {
    try {
        console.log('Paste area text:', text);
        
        if (!text) {
            alert('No data to parse');
            return;
        }
        
        // Split by newlines to get rows
        const rows = text.split('\n').map(row => row.trim()).filter(row => row.length > 0);
        
        console.log('Parsed rows:', rows);
        
        if (rows.length === 0) {
            alert('No data could be parsed.');
            return;
        }
        
        // Split each row by tabs or commas
        const data = rows.map(row => {
            let cells = row.split('\t');
            if (cells.length === 1) {
                cells = row.split(',');
            }
            return cells.map(cell => cell.trim());
        });
        
        console.log('Parsed data:', data);
        
        // Find max column count
        const maxCols = Math.max(...data.map(row => row.length));
        
        // Pad rows to have the same number of columns
        const paddedData = data.map(row => {
            while (row.length < maxCols) {
                row.push('');
            }
            return row;
        });
        
        console.log('Padded data:', paddedData);
        
        initializeGrid(paddedData);
    } catch (error) {
        console.error('Error in parseAndLoadData:', error);
        alert('Error parsing data: ' + error.message);
    }
}

async function pasteFromClipboard() {
    try {
        console.log('Attempting to read from clipboard...');
        const text = await navigator.clipboard.readText();
        console.log('Clipboard content:', text);
        parseAndLoadData(text);
    } catch (error) {
        console.error('Error reading from clipboard:', error);
        if (error.name === 'NotAllowedError') {
            alert('Clipboard access denied. Please allow clipboard access in browser permissions.');
        } else {
            alert('Error reading clipboard: ' + error.message + '\n\nMake sure you copied data from Excel first.');
        }
    }
}

// Handle Ctrl+V paste event
async function handlePaste(event) {
    try {
        // Prevent default paste behavior
        event.preventDefault();
        
        // Get clipboard data
        const text = await navigator.clipboard.readText();
        console.log('Pasted from clipboard via Ctrl+V:', text);
        
        parseAndLoadData(text);
    } catch (error) {
        console.error('Error reading from clipboard:', error);
        if (error.name === 'NotAllowedError') {
            alert('Clipboard access denied. Please allow clipboard access in browser permissions.');
        } else {
            alert('Error reading clipboard: ' + error.message);
        }
    }
}

function clearTable() {
    initializeGrid([]);
}

async function processData() {
    if (gridData.length === 0) {
        alert('No data to process. Please paste data first.');
        return;
    }
    
    // Get the process button and show loading state
    const processBtn = document.querySelector('button[onclick="processData()"]');
    const originalText = processBtn.textContent;
    processBtn.disabled = true;
    processBtn.textContent = 'Simulation en cours...';
    
    try {
        console.log('Sending data to server for processing:', gridData);
        
        // Convert to 2D array of numbers (assumes numeric data)
        const numericData = gridData.map(row => 
            row.map(cell => {
                const num = parseFloat(cell);
                return isNaN(num) ? 0 : num;
            })
        );
        
        const response = await fetch('/lyophilisation/array', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ data: numericData })
        });
        
        if (!response.ok) {
            throw new Error(`Server error: ${response.status} ${response.statusText}`);
        }
        
        const result = await response.json();
        console.log('Processing result:', result);
        
        processBtn.textContent = originalText;
        processBtn.style.backgroundColor = '';
        processBtn.disabled = false;
        
        
        displayResults(result);
    } catch (error) {
        console.error('Error processing data:', error);
        
        // Show error state
        processBtn.textContent = '✗ Erreur!';
        processBtn.style.backgroundColor = '#f44336';
        
        // Reset button after 2 seconds
        setTimeout(() => {
            processBtn.textContent = originalText;
            processBtn.style.backgroundColor = '';
            processBtn.disabled = false;
        }, 2000);
        
        alert('Error processing data: ' + error.message);
    }
}

function displayResults(result) {
    const resultsSection = document.getElementById('resultsSection');
    const resultsContent = document.getElementById('resultsContent');
    
    console.log('displayResults called with:', result);
    
    if (!resultsSection || !resultsContent) {
        console.error('Results section or content not found in DOM');
        alert('Error: Results section not found in page');
        return;
    }
    
    // Clear any previous table
    const previousTable = resultsSection.querySelector('table');
    if (previousTable) {
        previousTable.remove();
    }
    
    // // Format the results nicely
    // let output = 'Resultats';
    // resultsContent.textContent = output;
    resultsSection.style.display = 'block';
    
    // Try to find and display data from various possible response structures
    let dataToDisplay = null;
    
    if (result.received_data) {
        console.log('Found received_data:', result.received_data);
        dataToDisplay = result.received_data;
    } else if (result.data) {
        console.log('Found data:', result.data);
        dataToDisplay = result.data;
    } else {
        console.log('Using entire result as data'); 
        dataToDisplay = result;
    }
    
    // Try to display as table if possible
    if (dataToDisplay && typeof dataToDisplay === 'object') {
        try {
            displayDataTable(dataToDisplay, resultsContent);
        } catch (error) {
            console.error('Error displaying as table:', error);
            console.log('Falling back to JSON display');
            resultsContent.textContent = JSON.stringify(dataToDisplay, null, 2);
        }
    } else {
        console.log('Data is not an object, displaying as text');
        resultsContent.textContent = String(dataToDisplay);
    }
    
    // Scroll to results
    resultsSection.scrollIntoView({ behavior: 'smooth' });
}

function displayDataTable(dataDict, insertAfter) {
    // Convert dict of lists to table format
    // e.g., {'Ts': [1, 2, 3], 'Qw': [4, 5, 6]} becomes a table with columns Ts, Qw
    
    console.log('displayDataTable called with:', dataDict);
    
    // Handle case where dataDict is a simple array of values (strings, numbers)
    if (Array.isArray(dataDict)) {
        console.log('Data is an array, converting to table');
        
        // If it's an array of objects, use object keys as columns
        if (dataDict.length > 0 && typeof dataDict[0] === 'object' && !Array.isArray(dataDict[0])) {
            const keys = Object.keys(dataDict[0]);
            const dictOfLists = {};
            keys.forEach(key => {
                dictOfLists[key] = dataDict.map(row => row[key]);
            });
            displayDataTable(dictOfLists, insertAfter);
            return;
        }
        
        // If it's an array of arrays, treat as rows
        if (dataDict.length > 0 && Array.isArray(dataDict[0])) {
            const tableHtml = createTableFromArrayOfArrays(dataDict);
            insertAfter.insertAdjacentHTML('afterend', tableHtml);
            return;
        }
        
        // If it's a simple array of values, create a single-column table
        console.log('Data is a simple array of values');
        const tableHtml = createTableFromSimpleArray(dataDict);
        insertAfter.insertAdjacentHTML('afterend', tableHtml);
        return;
    }
    
    const keys = Object.keys(dataDict);
    console.log('Table keys:', keys);
    
    if (keys.length === 0) {
        console.warn('No keys found in dataDict');
        return;
    }
    
    // Check if values are arrays or scalars
    const firstValue = dataDict[keys[0]];
    const hasArrayValues = Array.isArray(firstValue);
    
    if (hasArrayValues) {
        // Dict of lists format
        console.log('Detected dict of lists format');
        
        // Get the max length of all lists
        let maxLength = 0;
        keys.forEach(key => {
            const arr = dataDict[key];
            if (Array.isArray(arr)) {
                maxLength = Math.max(maxLength, arr.length);
            }
        });
        
        console.log('Max length:', maxLength);
        
        if (maxLength === 0) {
            console.warn('No data rows found');
            return;
        }
        
        // Create table
        let tableHtml = '';
        tableHtml += '<table style="width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 13px;">';
        
        // Header row
        tableHtml += '<thead style="background-color: #e0e0e0;">';
        tableHtml += '<tr>';
        keys.forEach(key => {
            const displayTitle = getColumnTitle(key);
            tableHtml += `<th style="border: 1px solid #999; padding: 10px; text-align: left; font-weight: bold;">${displayTitle}</th>`;
        });
        tableHtml += '</tr>';
        tableHtml += '</thead>';
        
        // Data rows
        tableHtml += '<tbody>';
        for (let i = 0; i < maxLength; i++) {
            tableHtml += '<tr>';
            keys.forEach(key => {
                const arr = dataDict[key];
                let value = '';
                if (Array.isArray(arr) && i < arr.length) {
                    value = arr[i];
                }
                // Format numbers to 6 decimal places if they're numeric
                let displayValue = value;
                if (typeof value === 'number') {
                    displayValue = value.toFixed(6);
                }
                tableHtml += `<td style="border: 1px solid #ddd; padding: 8px;">${displayValue}</td>`;
            });
            tableHtml += '</tr>';
        }
        tableHtml += '</tbody>';
        tableHtml += '</table>';
        
        console.log('Inserting table after content');
        insertAfter.insertAdjacentHTML('afterend', tableHtml);
    } else {
        // Dict of scalars format - create two-column table
        console.log('Detected dict of scalars format');
        const tableHtml = createTableFromDictOfScalars(dataDict);
        insertAfter.insertAdjacentHTML('afterend', tableHtml);
    }
}

function createTableFromSimpleArray(data) {
    console.log('Creating table from simple array:', data);
    let tableHtml = '';
    tableHtml += '<table style="width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 13px;">';
    
    tableHtml += '<thead style="background-color: #e0e0e0;">';
    tableHtml += '<tr><th style="border: 1px solid #999; padding: 10px; text-align: left; font-weight: bold;">Value</th></tr>';
    tableHtml += '</thead>';
    
    tableHtml += '<tbody>';
    data.forEach(value => {
        let displayValue = value;
        if (typeof value === 'number') {
            displayValue = value.toFixed(6);
        } else if (typeof value === 'string') {
            const num = parseFloat(value);
            if (!isNaN(num)) {
                displayValue = num.toFixed(6);
            }
        }
        tableHtml += '<tr>';
        tableHtml += `<td style="border: 1px solid #ddd; padding: 8px;">${displayValue}</td>`;
        tableHtml += '</tr>';
    });
    tableHtml += '</tbody>';
    tableHtml += '</table>';
    
    return tableHtml;
}

function createTableFromDictOfScalars(dataDict) {
    console.log('Creating table from dict of scalars:', dataDict);
    let tableHtml = '';
    tableHtml += '<table style="width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 13px;">';
    
    tableHtml += '<thead style="background-color: #e0e0e0;">';
    tableHtml += '<tr>';
    tableHtml += `<th style="border: 1px solid #999; padding: 10px; text-align: left; font-weight: bold;">Key</th>`;
    tableHtml += `<th style="border: 1px solid #999; padding: 10px; text-align: left; font-weight: bold;">Value</th>`;
    tableHtml += '</tr>';
    tableHtml += '</thead>';
    
    tableHtml += '<tbody>';
    Object.keys(dataDict).forEach(key => {
        const value = dataDict[key];
        let displayValue = value;
        if (typeof value === 'number') {
            displayValue = value.toFixed(6);
        }
        let displayKey = getColumnTitle(key);
        // Try to format key as number if it's numeric (only if no mapping found)
        if (displayKey === key) {
            const keyNum = parseFloat(key);
            if (!isNaN(keyNum)) {
                displayKey = keyNum.toFixed(6);
            }
        }
        tableHtml += '<tr>';
        tableHtml += `<td style="border: 1px solid #ddd; padding: 8px;">${displayKey}</td>`;
        tableHtml += `<td style="border: 1px solid #ddd; padding: 8px;">${displayValue}</td>`;
        tableHtml += '</tr>';
    });
    tableHtml += '</tbody>';
    tableHtml += '</table>';
    
    return tableHtml;
}

function createTableFromArrayOfArrays(data) {
    let tableHtml = '';
    tableHtml += '<table style="width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 13px;">';
    
    // Get the number of columns from the first row
    const numCols = data.length > 0 && Array.isArray(data[0]) ? data[0].length : 0;
    
    // Add header row with hardcoded titles for first two columns
    const hardcodedTitles = ['Humidité résiduelle', 'Masse de glace (kg)'];
    tableHtml += '<thead style="background-color: #e0e0e0;">';
    tableHtml += '<tr>';
    for (let i = 0; i < numCols; i++) {
        const title = hardcodedTitles[i] || `Colonne ${i + 1}`;
        tableHtml += `<th style="border: 1px solid #999; padding: 10px; text-align: left; font-weight: bold;">${title}</th>`;
    }
    tableHtml += '</tr>';
    tableHtml += '</thead>';
    
    tableHtml += '<tbody>';
    data.forEach(row => {
        tableHtml += '<tr>';
        if (Array.isArray(row)) {
            row.forEach(cell => {
                let displayValue = cell;
                if (typeof cell === 'number') {
                    displayValue = cell.toFixed(6);
                }
                tableHtml += `<td style="border: 1px solid #ddd; padding: 8px;">${displayValue}</td>`;
            });
        } else {
            tableHtml += `<td style="border: 1px solid #ddd; padding: 8px;">${row}</td>`;
        }
        tableHtml += '</tr>';
    });
    tableHtml += '</tbody>';
    tableHtml += '</table>';
    
    return tableHtml;
}

function clearResults() {
    const resultsSection = document.getElementById('resultsSection');
    const resultsContent = document.getElementById('resultsContent');
    
    resultsSection.style.display = 'none';
    resultsContent.textContent = '';
    
    // Remove any appended tables
    const table = resultsSection.querySelector('table');
    if (table) {
        table.remove();
    }
    const heading = resultsSection.querySelector('h3');
    if (heading) {
        heading.remove();
    }
}

// Initialize empty grid on page load
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM Content Loaded');
    console.log('window.GlideDataGrid:', window.GlideDataGrid);
    initializeGrid();
    
    // Listen for paste events
    document.addEventListener('paste', handlePaste);
    console.log('Paste event listener attached - use Ctrl+V to paste from Excel');
});

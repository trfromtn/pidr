// Initialize Glide Data Grid
let grid;
let gridData = [];
let useSimpleTable = false;

function initializeGrid(data = []) {
    const container = document.getElementById('gridContainer');
    
    // Default empty grid
    if (data.length === 0) {
        data = [
            ['', '', ''],
            ['', '', ''],
            ['', '', '']
        ];
    }
    
    gridData = JSON.parse(JSON.stringify(data)); // Deep copy
    
    // Get dimensions
    const numRows = data.length;
    const numCols = data.length > 0 ? data[0].length : 3;
    
    // Clear container
    container.innerHTML = '';
    
    try {
        // Try to use glide data grid
        if (typeof window.GlideDataGrid !== 'undefined' && !useSimpleTable) {
            console.log('Using Glide Data Grid');
            initializeGlideGrid(data);
        } else {
            console.log('Using simple HTML table');
            initializeSimpleTable(data);
        }
    } catch (error) {
        console.error('Error initializing grid:', error);
        console.log('Falling back to simple table');
        useSimpleTable = true;
        initializeSimpleTable(data);
    }
}

function initializeGlideGrid(data) {
    const container = document.getElementById('gridContainer');
    const numRows = data.length;
    const numCols = data.length > 0 ? data[0].length : 3;
    
    const { DataEditor, GridCellKind } = window.GlideDataGrid;
    
    // Create column definitions
    const columns = Array.from({ length: numCols }, (_, i) => ({
        title: String.fromCharCode(65 + i), // A, B, C, etc.
        width: 120,
    }));
    
    // Create grid
    grid = new DataEditor({
        defaultWidth: 120,
        defaultHeight: 32,
        width: container.offsetWidth,
        height: 500,
        columns: columns,
        rows: numRows,
        getCellContent: (cell) => {
            const [col, row] = cell;
            const value = gridData[row]?.[col] || '';
            return {
                kind: GridCellKind.Text,
                text: String(value),
                displayText: String(value),
                allowOverlay: true,
                readonly: false,
            };
        },
        onCellEdited: (cell, newValue) => {
            const [col, row] = cell;
            if (!gridData[row]) {
                gridData[row] = [];
            }
            if (newValue.kind === GridCellKind.Text) {
                gridData[row][col] = newValue.text;
            }
        },
    });
    
    grid.attachToElement(container);
    console.log('Glide grid initialized successfully');
    
    // Handle window resize
    window.addEventListener('resize', () => {
        if (grid) {
            grid.setSize({
                width: container.offsetWidth,
                height: 500,
            });
        }
    });
}

function initializeSimpleTable(data) {
    const container = document.getElementById('gridContainer');
    const numRows = data.length;
    const numCols = data.length > 0 ? data[0].length : 3;
    
    let html = '<table style="width: 100%; border-collapse: collapse; font-size: 14px;">';
    
    // Header row
    html += '<thead style="background-color: #f0f0f0;">';
    html += '<tr>';
    for (let c = 0; c < numCols; c++) {
        html += `<th style="border: 1px solid #ddd; padding: 8px; text-align: left; font-weight: bold;">
                    ${String.fromCharCode(65 + c)}
                 </th>`;
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
            html += `<td style="border: 1px solid #ddd; padding: 0;">
                        <input 
                            type="text" 
                            id="${cellId}"
                            value="${value.replace(/"/g, '&quot;')}"
                            style="width: 100%; border: none; padding: 8px; box-sizing: border-box;"
                            onchange="updateGridData(${r}, ${c}, this.value)"
                        />
                     </td>`;
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
    document.getElementById('pasteArea').value = '';
    initializeGrid([]);
}

async function processData() {
    if (gridData.length === 0) {
        alert('No data to process. Please paste data first.');
        return;
    }
    
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
        
        displayResults(result);
    } catch (error) {
        console.error('Error processing data:', error);
        alert('Error processing data: ' + error.message);
    }
}

function displayResults(result) {
    const resultsSection = document.getElementById('resultsSection');
    const resultsContent = document.getElementById('resultsContent');
    
    // Format the results nicely
    let output = 'Status: ' + result.status + '\n\n';
    
    if (result.received_data) {
        output += 'Received Data:\n';
        output += JSON.stringify(result.received_data, null, 2);
    }
    
    resultsContent.textContent = output;
    resultsSection.style.display = 'block';
    
    // Scroll to results
    resultsSection.scrollIntoView({ behavior: 'smooth' });
}

function clearResults() {
    document.getElementById('resultsSection').style.display = 'none';
    document.getElementById('resultsContent').textContent = '';
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

const data = [
    ["", ""]
];

// Configuration des colonnes (noms et types)
const columns = [
    { title: "Temperature Shelf", type: 'numeric' },
    { title: "Methode", type: 'text' },
];

// Initialisation du tableur
const hot = new Handsontable(document.getElementById('table'), {
    data: data,
    columns: columns,
    rowHeaders: true,
    colHeaders: true,
    stretchH: 'all',
    height: 'auto',
    licenseKey: 'non-commercial-and-evaluation', // Clé pour usage non commercial
    contextMenu: true,
    manualRowResize: false,
    manualColumnResize: true,
    outsideClickDeselects: false,
});

// Initialisation de la table de résultats
let resultsHot = null;

function initializeResultsTable(resultsData) {
    if (resultsHot) {
        resultsHot.destroy();
    }
    
    const resultColumns = resultsData[0].map((_, index) => ({
        title: `Résultat ${index + 1}`,
        type: 'numeric'
    }));
    
    resultsHot = new Handsontable(document.getElementById('results-table'), {
        data: resultsData,
        columns: resultColumns,
        rowHeaders: true,
        colHeaders: true,
        stretchH: 'all',
        height: 'auto',
        licenseKey: 'non-commercial-and-evaluation',
        contextMenu: true,
        manualRowResize: false,
        manualColumnResize: true,
        outsideClickDeselects: false,
    });
}

// Fonction pour coller des données depuis un tableur
function pasteData() {
    navigator.clipboard.readText().then(text => {
    const rows = text.split('\n');
    const tableData = rows.map(row => row.split('\t'));
    hot.loadData(tableData);
    }).catch(err => {
    console.error('Erreur lors du collage : ', err);
    alert("Impossible d'accéder au presse-papiers. Utilise Ctrl+V directement dans le tableur.");
    });
}

// Fonction pour envoyer les données à l'API
function sendData() {
    const tableData = hot.getData();
    
    fetch('/lyophilisation/array', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ data: tableData })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`Erreur HTTP: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        console.log('Succès:', data);
        if (data.received_data) {
            initializeResultsTable(data.received_data);
            // alert('Données envoyées et résultats reçus avec succès');
            console.log("Data reçue correctement affichée")
        }
    })
    .catch(error => {
        console.error('Erreur lors de l\'envoi:', error);
        alert('Erreur lors de l\'envoi des données');
    });
}


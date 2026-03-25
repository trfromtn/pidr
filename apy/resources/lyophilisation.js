const data = [
    ["", "", "", "", ""],
    ["", "", "", "", ""],
    ["", "", "", "", ""],
    ["", "", "", "", ""],
    ["", "", "", "", ""],
];

// Configuration des colonnes (noms et types)
const columns = [
    { title: "Nom", type: 'text' },
    { title: "Prénom", type: 'text' },
    { title: "Âge", type: 'numeric' },
    { title: "Ville", type: 'text' },
    { title: "Pays", type: 'text' },
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
    manualRowResize: true,
    manualColumnResize: true,
    outsideClickDeselects: false,
});

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
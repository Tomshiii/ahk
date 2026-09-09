const vscode = require('vscode');

// The exact identifier text we want to single out.
const TARGET_TEXT = 'null';
// The semantic token type it will carry (as seen in your Inspect Editor Tokens output).
const TARGET_TOKEN_TYPE = 'class';
// Colour to force onto matching ranges.
const TARGET_COLOR = '#D19A66';

let decorationType;
let debounceTimer;
// Cache of {tokenTypes: [...]} legend per-document-uri-string, since the legend
// for a given language/provider doesn't change between calls.
const legendCache = new Map();

function activate(context) {
    decorationType = vscode.window.createTextEditorDecorationType({
        color: TARGET_COLOR
    });
    context.subscriptions.push(decorationType);

    // Re-run whenever the active editor changes.
    context.subscriptions.push(
        vscode.window.onDidChangeActiveTextEditor(editor => {
            if (editor) scheduleUpdate(editor);
        })
    );

    // Re-run on edits, debounced so we don't hammer the language server on every keystroke.
    context.subscriptions.push(
        vscode.workspace.onDidChangeTextDocument(event => {
            const editor = vscode.window.activeTextEditor;
            if (editor && event.document === editor.document) {
                scheduleUpdate(editor);
            }
        })
    );

    // Run once for whatever's already open.
    if (vscode.window.activeTextEditor) {
        scheduleUpdate(vscode.window.activeTextEditor);
    }
}

function scheduleUpdate(editor) {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => updateDecorations(editor), 200);
}

async function updateDecorations(editor) {
    if (!editor || editor.document.languageId !== 'ahk2') {
        return;
    }

    const doc = editor.document;
    const uri = doc.uri;

    try {
        const legend = await getLegend(uri);
        if (!legend) return;

        const classIndex = legend.tokenTypes.indexOf(TARGET_TOKEN_TYPE);
        if (classIndex === -1) return; // this language's providers don't expose a "class" type

        const tokens = await vscode.commands.executeCommand(
            'vscode.provideDocumentSemanticTokens',
            uri
        );
        if (!tokens) return;

        const ranges = decodeMatchingRanges(doc, tokens.data, classIndex);
        editor.setDecorations(decorationType, ranges);
    } catch (err) {
        // Language server may not be ready yet (e.g. right after opening a file) - ignore and retry on next edit.
        console.error('ahk2-null-highlight:', err);
    }
}

async function getLegend(uri) {
    const key = uri.toString();
    if (legendCache.has(key)) return legendCache.get(key);

    const legend = await vscode.commands.executeCommand(
        'vscode.provideDocumentSemanticTokensLegend',
        uri
    );
    if (legend) legendCache.set(key, legend);
    return legend;
}

// Semantic token data is a flat Uint32Array, 5 integers per token:
// [deltaLine, deltaStartChar, length, tokenType, tokenModifiers]
// Positions are relative to the previous token (resetting deltaStartChar
// only when deltaLine is 0), per the LSP semantic tokens spec.
function decodeMatchingRanges(doc, data, classIndex) {
    const ranges = [];
    let line = 0;
    let char = 0;

    for (let i = 0; i < data.length; i += 5) {
        const deltaLine = data[i];
        const deltaStart = data[i + 1];
        const length = data[i + 2];
        const tokenType = data[i + 3];

        if (deltaLine === 0) {
            char += deltaStart;
        } else {
            line += deltaLine;
            char = deltaStart;
        }

        if (tokenType === classIndex) {
            const range = new vscode.Range(line, char, line, char + length);
            const text = doc.getText(range);
            if (text === TARGET_TEXT) {
                ranges.push(range);
            }
        }
    }

    return ranges;
}

function deactivate() {}

module.exports = { activate, deactivate };

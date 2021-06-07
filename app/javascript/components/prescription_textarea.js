const nbWordsInLines = (lines) => {
  var result = 0;
  lines.forEach((line) => {
    result += line.trim().split(" ").length; // trim because some browsers add white space after each word
  });
  return result;
};

const tooMuchLineBreaks = (text) => {
  const lines = text.split(/\r?\n|\r/g);
  const nbLines = lines.length;
  const nbWords = nbWordsInLines(lines);
  if (nbLines <= 3) {
    return false;
  }
  return nbLines == nbWords;
};

const removeLineBreaks = (text) => {
  return text.replace(/\r?\n|\r/g, " ").replace(/  /g, " ");
};

const getTextToPaste = (event) => {
  const toPaste = (event.clipboardData || window.clipboardData).getData("text");
  return tooMuchLineBreaks(toPaste) ? removeLineBreaks(toPaste) : toPaste;
};

const pasteText = (textarea, toPaste) => {
  const start = textarea.selectionStart;
  const end = textarea.selectionEnd;

  const textBefore = textarea.value.slice(0, start);
  const textAfter = textarea.value.slice(end);

  const newText = textBefore + toPaste + textAfter;
  textarea.value = newText;
};

const removeLineBreaksWhenTooMany = (event) => {
  toPaste = getTextToPaste(event);
  pasteText(event.target, toPaste);
  event.preventDefault();
};

window.addEventListener("load", () => {
  const textAreas = document.querySelectorAll("#prescription_content");
  textAreas.forEach((textArea) => {
    textArea.addEventListener("paste", removeLineBreaksWhenTooMany);
  });
});

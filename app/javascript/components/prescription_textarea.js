const nbWordsInLines = (lines) => {
  var result = 0;
  lines.forEach((line) => {
    result += line.split(" ").length;
  });
  return result;
};

const tooMuchLineBreaks = (text) => {
  const lines = text.split("\n");
  const nbLines = lines.length;
  const nbWords = nbWordsInLines(lines);
  if (nbLines <= 3) {
    return false;
  }
  return nbLines == nbWords;
};

const removeLineBreaks = (text) => {
  return text.replaceAll("\n", " ");
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
  pasteText(event.srcElement, toPaste);
  event.preventDefault();
};

window.addEventListener("load", () => {
  const textAreas = document.querySelectorAll("#prescription_content");
  textAreas.forEach((textArea) => {
    textArea.addEventListener("paste", removeLineBreaksWhenTooMany);
  });
});

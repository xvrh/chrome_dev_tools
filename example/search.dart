import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await Browser.start();
  var page = await browser.newPage();

  await page.goto('https://developers.google.com/web/');

  // Type into search box.
  await page.type('#searchbox input', 'Headless Chrome');

  // Wait for suggest overlay to appear and click "show all results".
  var allResultsSelector = '.devsite-suggest-all-results';
  await page.waitForSelector(allResultsSelector);
  await page.click(allResultsSelector);

  // Wait for the results page to load and display the results.
  const resultsSelector = '.gsc-results .gsc-thumbnail-inside a.gs-title';
  await page.waitForSelector(resultsSelector);

  // Extract the results from the page.
  var links = await page.evaluate(r'''resultsSelector => {
  const anchors = Array.from(document.querySelectorAll(resultsSelector));
  return anchors.map(anchor => {
    const title = anchor.textContent.split('|')[0].trim();
    return `${title} - ${anchor.href}`;
  });
}''', args: [resultsSelector]);
  print(links.join('\n'));

  await browser.close();
}
const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  await page.goto('https://nhattruyenmin.com/', { waitUntil: 'networkidle0' });
  await page.waitForSelector('#ctl00_Body');
  const htmlContent = await page.content();
  console.log(htmlContent);

  await browser.close();
})();

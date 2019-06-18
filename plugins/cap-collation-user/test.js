const pup = require ('puppeteer-core');
const fs = require ('fs').promises;

const options = {
    executablePath  : '/usr/bin/chromium',
    headless        : false,
    // slowMo          : 1000,
    defaultViewport : { width: 1200, height : 1200 },
};

async function dropdown_select (page, selector) {
    await page.waitForSelector (selector);
    await page.$eval (selector, button => $ (button).parent ().addClass ('show'));
    await page.click (selector);
    await page.$eval (selector, button => $ (button).parent ().removeClass ('show'));
}

pup.launch (options).then (async browser => {
    const page = await browser.newPage ();
    await page.goto ('http://capitularia.fritz.box/tools/collation/', { waitUntil : 'load' });

    await dropdown_select (page, '#bk button[data-bk="BK.143"]');
    console.log ('first select');

    await dropdown_select (page, '#corresp button[data-corresp="BK.143_2"]');
    console.log ('second select');

    await page.waitForSelector ('#cb-select-wolfenbuettel-hab-blankenb-130');
    await page.waitFor (100);
    await page.click ('#cb-select-all-1');
    await page.waitFor (100);
    await page.click ('#btn-collate');
    console.log ('start collate');

    await page.waitForSelector ('#collation-results tr[data-siglum="wolfenbuettel-hab-blankenb-130"]');
    await page.waitFor (500);
    console.log ('collated');

    const html = await page.content ();

    await fs.writeFile ('puppeteer.html', html);

    await browser.close ();
});

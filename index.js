const yargs = require('yargs');

const argv = yargs
    .usage('Usage: [sketchfile]')
    .help('h')
    .alias('h', 'help')
    .example('~/Documents/example.sketch')
    .alias('o', 'output')
    .describe('o', 'Configure the output directory for generated Elm')
    .default('o', 'generated')
    .alias('ef', 'elmformat')
    .describe('elmformat', 'Specify the location of the elm-format binary')
    .default('elmformat', 'elm-format')
    .argv;

const fs = require('fs');
const path = require('path');
const decompress = require('decompress');
const ProgressBar = require("progress");
const childProcess = require("child_process");
const Elm = require('./elm.js');


if (argv._.length === 0){
    console.log('Please provide a file to convert to Elm!');
    process.exit(1);
}

const options = {
    files: argv._, 
    rootDir: argv.output,
    elmFormatPath: argv.ef
};

function createOutputDirectory(rootDir) {
    try {
        fs.mkdirSync(rootDir);
    } catch (e){}

    try {
        fs.mkdirSync(path.join(rootDir, "images"));
    } catch (e) {}
}



function main () {
    createOutputDirectory(options.rootDir);
    var elmApp = Elm.Runner.worker();
    var pageCount = 0;

    decompress(options.files[0]).then(function(files){
        // send in image file names to elm
        const imageFiles = files
            .filter(function(file) { return file.path.indexOf("images") === 0 })
            .map(function(file) { return file.path });

        elmApp.ports.knownImages.send(imageFiles);

        // grab the page files
        const pageFiles = files
            .filter(function(file) { return file.path.indexOf("pages") === 0});

        // setup a progress bar going from 0 to the number of pages
        const progressBar = new ProgressBar(
          "Generating pages: :page [:bar] :percent",
          { total: pageFiles.length }
        );

        // respond to content from Elm
        elmApp.ports.respond.subscribe(function(data){
            pageCount++;
            const pageName = `Page${pageCount}.elm`;
            const outputLocation = path.join(options.rootDir, pageName);
            fs.writeFile(outputLocation, data, function(){
                childProcess.execSync(options.elmFormatPath + " --yes " + outputLocation,
                    { stdio: [] }
                );
                progressBar.tick({ page: pageName });
            });
        });

        // send our data over to Elm to parse
        pageFiles.forEach(function(file){
            elmApp.ports.parse.send(file.data.toString('utf-8'));
        });

        // write the images
        files
        .filter(function(file) { return file.path.indexOf("images") === 0})
        .forEach(function(file){
            fs.writeFileSync(path.join(options.rootDir, file.path), file.data);
        });

        console.log(`Done! Generated files at ${path.join(__dirname, options.rootDir)}`);
    }).catch(function(err){
        console.error(err);
    });

}

main();
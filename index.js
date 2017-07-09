var argv = require('yargs').argv;

var fs = require('fs');
var decompress = require('decompress');
var Elm = require('./elm.js');


var options = {
    output: "Main.elm",
    files: argv._
};


function main () {
    var elmApp = Elm.Runner.worker();

    try {
        fs.mkdirSync("generated");
        
    } catch (e){}

    try {
        fs.mkdirSync("generated/images");
    } catch (e) {}

    var pageCount = 0;
    elmApp.ports.respond.subscribe(function(data){
        pageCount++;

        fs.writeFile("generated/Page" + pageCount + ".elm", data, function(){
            console.log('exiting');
            process.exit()
        });
    })

    if (options.files.length == 0){
        console.error("Please provide a source .sketch file!");
        return;
    }

    if (typeof argv.output !== "undefined") {
        options.output = argv.output;
    }


    decompress(options.files[0]).then(function(files){

        files
        .filter(function(file) { return file.path.indexOf("pages") === 0})
        .forEach(function(file){
            elmApp.ports.parse.send(file.data.toString('utf-8'));
        });

        files
        .filter(function(file) { return file.path.indexOf("images") === 0})
        .forEach(function(file){
            fs.writeFileSync("generated/" + file.path, file.data);
        });
    }).catch(function(err){
        console.error(err);
    });

    console.log("done");

}

main();
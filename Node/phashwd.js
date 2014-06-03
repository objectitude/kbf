#! /usr/bin/nodejs

// JavaScript implementation (as CLI) of the PassForge tool

//salt password target

// card pwd SIM

var FirstArg = 2;
var salt = process.argv[FirstArg];
var target = process.argv[FirstArg + 1];
var key = process.argv[FirstArg + 2];

var crypto = require("crypto");

function HexaValue()
{
    var value = [];
    var index = 0;
}

HexaValue.prototype = 
{
    constructor: HexaValue,
    reset: function ()
    {
        this.index = 0;
    },

    GetValue: function ()
    {
        return this.value.join("");
    },

    SetValue: function (hex)
    {
        this.reset();
        this.value = hex.split("");
    },

    GetLength: function ()
    {
        return this.value.length / 2;
    },

    GetIndex: function ()
    {
        return this.index;
    },

     GetSlice: function (size)
    {
        //result = parseInt(this.value.slice(2 * this.index, 2 * (this.index + 1)).join(""), 16);
        result = parseInt(this.value.slice(2 * this.index, 2 * (this.index + size)).join(""), 16);
        this.index += size;
        console.log("Index: " + this.index);
        return result;
    }
}

function Slicer()
{
    var divident = 0;
    var remainder = 0;
    var supplement = 0;
}

Slicer.prototype = 
{
    constructor: Slicer,

    SetDivision: function (numerator, dividor)
    {
        this.divident = Math.floor(numerator / dividor);
        this.remainder = numerator % dividor;
        this.supplement = this.remainder;
    },

    GetDivident: function ()
    {
        return this.divident;
    },

    GetRemainder: function ()
    {
        return this.remainder;
    },

    GetSupplement: function ()
    {
        return this.supplement;
    },

    GetSliceLength: function ()
    {
        var result = NaN;
        //if (this.remainder - this.supplement <= this.divident)
        {
            result = this.divident + (this.supplement > 0 ? 1 : 0);
            -- this.supplement;
        }
        return result;
    }
}

var hash = function (salt, password, target)
{
    checksum = crypto.createHash("sha256");
    checksum.update(salt + password + target, "binary");
    return checksum.digest("hex");
}

var hashed = hash(salt, key, target);
console.log('Password: ' + hashed);
console.log(salt + key + target);

var digits = new HexaValue;
digits.SetValue(hashed);
var alls = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~".split("");
console.log('Characters: ' + alls.length + " " + digits.GetLength());

while (digits.GetIndex() < digits.GetLength())
{
    var slice = digits.GetSlice(4)
    console.log('Code:' + slice + ' ' + slice % 94 + ' ' + alls[slice % 94]);
}

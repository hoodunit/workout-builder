"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.render = void 0;
var React = require("react");
var ReactDOM = require("react-dom");
var MuscleBarChart_1 = require("root/Client/Charts/MuscleBarChart");
var render = function (elemId) { return function (props) { return function (val) {
    var elem = document.getElementById(elemId);
    if (!elem) {
        setTimeout(function () {
            exports.render(elemId)(props)(val);
        }, 0);
        return val;
    }
    try {
        ReactDOM.render(React.createElement(MuscleBarChart_1.MuscleBarChart, __assign({}, props)), elem);
    }
    catch (e) {
        console.error('Bar chart rendering failed', e);
        return val;
    }
    return val;
}; }; };
exports.render = render;
//# sourceMappingURL=Charts.js.map
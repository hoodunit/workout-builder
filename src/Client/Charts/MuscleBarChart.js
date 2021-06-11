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
var __spreadArray = (this && this.__spreadArray) || function (to, from) {
    for (var i = 0, il = from.length, j = to.length; i < il; i++, j++)
        to[j] = from[i];
    return to;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MuscleBarChart = void 0;
var React = require("react");
var recharts_1 = require("recharts");
var MuscleBarChart = function (props) {
    var muscles = props.muscles, barData = props.barData;
    var groups = Object.keys(barData);
    var groupDivisions = groups.map(function (group, i) {
        var line = i === 0 ? [] : [muscleGroupLine(barData[group][0].name)];
        return __spreadArray(__spreadArray([], line), [muscleGroupArea(barData[group], group)]);
    });
    var data = Object.values(barData).flat();
    return (React.createElement(recharts_1.ResponsiveContainer, { className: "chart", width: "100%", height: "100%" },
        React.createElement(recharts_1.BarChart, { width: 500, height: 300, data: data, margin: {
                top: 20,
                right: 30,
                left: 20,
                bottom: 5,
            } },
            React.createElement(recharts_1.XAxis, __assign({}, { angle: -90 }, { dataKey: "name", textAnchor: "end", height: 180, interval: 0 })),
            React.createElement(recharts_1.YAxis, __assign({}, { domain: [0, 50], label: { value: "Sets per week", angle: -90 }, position: "insideLeft" })),
            React.createElement(recharts_1.Tooltip, { content: MuscleTooltip(muscles) }),
            groupDivisions.flat(),
            React.createElement(recharts_1.ReferenceLine, { y: 10, strokeDasharray: "3 3", className: "reference-line reference-line--strength" }),
            React.createElement(recharts_1.ReferenceLine, { y: 15, strokeDasharray: "3 3", className: "reference-line reference-line--hypertrophy" }),
            React.createElement(recharts_1.ReferenceLine, { y: 20, strokeDasharray: "3 3", className: "reference-line reference-line--strength" }),
            React.createElement(recharts_1.ReferenceLine, { y: 30, strokeDasharray: "3 3", className: "reference-line reference-line--hypertrophy" }),
            React.createElement(recharts_1.ReferenceArea, { y1: 15, y2: 30, label: { value: "Hypertrophy range", position: "center", offset: 10 }, className: "reference reference-hypertrophy" }),
            React.createElement(recharts_1.ReferenceArea, { y1: 10, y2: 20, label: { value: "Strength range", position: "insideTop", offset: 10 }, className: "reference reference-strength" }),
            React.createElement(recharts_1.Bar, { dataKey: "targetIsolation", stackId: "primary", className: "bar bar--isolation", maxBarSize: 15 }),
            React.createElement(recharts_1.Bar, { dataKey: "targetCompound", stackId: "primary", className: "bar bar--compound", maxBarSize: 15 }),
            React.createElement(recharts_1.Bar, { dataKey: "synergists", stackId: "primary", className: "bar bar--synergist", maxBarSize: 15 }),
            React.createElement(recharts_1.Bar, { dataKey: "stabilizers", stackId: "primary", className: "bar bar--stabilizer", maxBarSize: 8 }))));
};
exports.MuscleBarChart = MuscleBarChart;
var round = function (val) {
    return Math.round(val * 10) / 10;
};
var MuscleTooltip = function (muscles) { return function (_a) {
    var active = _a.active, payload = _a.payload, label = _a.label;
    if (!active || !payload || !payload.length) {
        return null;
    }
    var _b = payload[0].payload, targetIsolation = _b.targetIsolation, targetCompound = _b.targetCompound, synergists = _b.synergists, stabilizers = _b.stabilizers;
    var total = targetIsolation + targetCompound + synergists + stabilizers;
    var exercises = muscles[label];
    var exerciseCell = function (exs) {
        if (!exs) {
            return null;
        }
        return exs.map(function (ex) { return React.createElement("div", null, ex); });
    };
    return (React.createElement("div", { className: "tooltip" },
        React.createElement("div", { className: "tooltip__title" },
            React.createElement("table", { className: "tooltip__table" },
                React.createElement("tbody", null,
                    targetIsolation > 0 && React.createElement("tr", { className: "tooltip__tr--isolation" },
                        React.createElement("td", { className: "tooltip__td--label" }, "Targeted (isolation)"),
                        React.createElement("td", { className: "tooltip__td--text" }, exerciseCell(exercises === null || exercises === void 0 ? void 0 : exercises.targetIsolation)),
                        React.createElement("td", { className: "tooltip__td--value" }, round(targetIsolation) + " sets")),
                    targetCompound > 0 && React.createElement("tr", { className: "tooltip__tr--compound" },
                        React.createElement("td", { className: "tooltip__td--label" }, "Targeted (compound)"),
                        React.createElement("td", { className: "tooltip__td--text" }, exerciseCell(exercises === null || exercises === void 0 ? void 0 : exercises.targetCompound)),
                        React.createElement("td", { className: "tooltip__td--value" }, round(targetCompound) + " sets")),
                    synergists > 0 && React.createElement("tr", { className: "tooltip__tr--synergist" },
                        React.createElement("td", { className: "tooltip__td--label" }, "Supporting"),
                        React.createElement("td", { className: "tooltip__td--text" }, exerciseCell(exercises === null || exercises === void 0 ? void 0 : exercises.synergists)),
                        React.createElement("td", { className: "tooltip__td--value" }, round(synergists) + " sets")),
                    stabilizers > 0 && React.createElement("tr", { className: "tooltip__tr--stabilizer" },
                        React.createElement("td", { className: "tooltip__td--label" }, "Stabilizers"),
                        React.createElement("td", { className: "tooltip__td--text" }, exerciseCell(exercises === null || exercises === void 0 ? void 0 : exercises.stabilizers)),
                        React.createElement("td", { className: "tooltip__td--value" }, round(stabilizers) + " sets")),
                    React.createElement("tr", null,
                        React.createElement("td", { className: "tooltip__td--label" }),
                        React.createElement("td", null),
                        React.createElement("td", { className: "tooltip__td--value" }, round(total) + " sets")))))));
}; };
var muscleGroupArea = function (group, name) {
    return React.createElement(recharts_1.ReferenceArea, { x1: group[0].name, x2: group[group.length - 1].name, ifOverflow: "visible", label: { value: name, position: "insideTop", offset: 10 }, className: "reference-area--muscle-group" });
};
var muscleGroupLine = function (x) {
    return React.createElement(recharts_1.ReferenceLine, { x: x, strokeDasharray: "3 3", position: "start", className: "reference-line reference-line--bodypart" });
};
//# sourceMappingURL=MuscleBarChart.js.map
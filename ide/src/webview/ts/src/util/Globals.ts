import Node from './Node';
import State from './State';
import Tree from './Tree';
import Listview from './Listview';

declare var acquireVsCodeApi: any;
declare var d3: any;

export default class Globals {
    public static s = new State();
    public static lv = new Listview();
    public static vscode = acquireVsCodeApi();
    public static columns = ["name", "rng"];

    public static tabulate() {
        var table = d3.select('#pane').append('table');
        var thead = table.append('thead');

        // append the header row
        thead.append('tr')
            .selectAll('th')
            .data(Globals.columns).enter()
            .append('th')
            .text(function (column: any) { return column; });
    }

    public static appendRows(data: any) {
        var table = d3.select('#pane').append('table');
        var tbody = table.append('tbody');

        var rows = tbody.selectAll('tr')
            .data(data)
            .enter()
            .append('tr')
            .attr("id", (d: any, i: any) => { return d.name; });

        // create a cell in each row for each column
        rows.selectAll('td')
            .data((row: any) => {
                return Globals.columns.map((column) => {
                    return { column: column, value: row[column] };
                });
            })
            .enter()
            .append('td')
            .text((d: any) => { return d.value; });
    }

    public static previousSolutionNode(){

        if (Globals.s.solNodIds.length === 0){
            return;
        }

        if (!Globals.s.solNodIds.includes(Globals.s.selectedId)){
            Globals.s.selectedId = Globals.s.solNodIds[Globals.s.solNodIds.length - 1];
            return;
        }

        let currentSolId = Globals.s.solNodIds.indexOf(Globals.s.selectedId);

        if (currentSolId - 1 >= 0){
            Globals.s.selectedId = Globals.s.solNodIds[currentSolId - 1];
        }
    }


    public static nextSolutionNode(){

        if (Globals.s.solNodIds.length === 0){
            return;
        }

        if (!Globals.s.solNodIds.includes(Globals.s.selectedId)){
            Globals.s.selectedId = Globals.s.solNodIds[0];
            return;
        }

        let currentSolId = Globals.s.solNodIds.indexOf(Globals.s.selectedId);

        if (currentSolId + 1 < Globals.s.solNodIds.length){
            Globals.s.selectedId = Globals.s.solNodIds[currentSolId + 1];
        }
    }


    public static nextNode() {

        // let stepSize = Number($("#stepSize").val());
        let stepSize = 1;

        let node = Globals.s.id2Node[Globals.s.selectedId];

        // console.log("current");
        // console.log(node);

        if (node._children) {
            Node.toggleNode(node);
            return;
        }

        if (!Globals.s.id2Node[Globals.s.selectedId + stepSize]) {
            Globals.loadNNodes();
        }
        else {
            Globals.s.selectedId += stepSize;
            Tree.selectNode(Globals.s.selectedId);
        }
    }

    public static previousNode() {

        let prevId = Globals.s.selectedId - 1;

        if (Globals.s.id2Node[prevId]) {
            Globals.s.selectedId--;
            Tree.selectNode(Globals.s.selectedId);
        }
    }

    public static rightNode() {
        if (Globals.s.id2Node[Globals.s.selectedId].children) {
            let childCount = Globals.s.id2Node[Globals.s.selectedId].children!.length;
            if (childCount > 1) {
                Globals.s.selectedId = Globals.s.id2Node[Globals.s.selectedId].children![childCount - 1].id;
            }
            Tree.selectNode(Globals.s.selectedId);
        }
    }

    public static upNode() {
        if (Globals.s.selectedId > Globals.s.rootId) {
            Globals.s.selectedId = Globals.s.id2Node[Globals.s.selectedId].parent!.id;
        }
        Tree.selectNode(Globals.s.selectedId);
    }

    public static loadNNodes() {

        if (!Globals.s.waiting) {

            Globals.vscode.postMessage({
                command: 'loadNodes',
                // amount: Number($("#stepSize").val()),
                amount: 1,
                start: Globals.s.selectedId
            });

            Globals.s.waiting = true;
        }
    }

    public static loadDomains() {

        if (!Globals.s.waiting) {

            if (Globals.s.pretty) {
                Globals.sendPrettyRequest();
            }
            else {
                Globals.sendSimpleRequest();
            }

            Globals.s.waiting = true;
        }
    }

    public static sendSimpleRequest() {
        Globals.vscode.postMessage({
            command: "simpleDomains",
            nodeId: Globals.s.selectedId,
            wantExpressions: !$("#expressions").prop("checked"),
        });
    }

    public static sendPrettyRequest() {
        Globals.vscode.postMessage({
            command: "prettyDomains",
            nodeId: Globals.s.selectedId,
            wantExpressions: !$("#expressions").prop("checked"),
            paths: Globals.s.pathList.join(":")
        });
    }

    public static loadChildIds(nodeId: number) {
        Globals.vscode.postMessage({
            command: 'loadChildren',
            id: nodeId,
        });
    }

    public static initialize() {
        Globals.vscode.postMessage({
            command: 'init',
        });

        Globals.vscode.postMessage({
            command: 'longestBranchingVariable',
        });

        // Globals.vscode.postMessage({
        //     command: 'loadCore',
        // });
    }
}
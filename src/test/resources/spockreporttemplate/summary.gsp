= Spock Test Results
// toc-title definition MUST follow document title without blank line!
:toc-title: Table of Contents
:toclevels: 4


<%
    //pitest
    //&#x20E0;
    //def monsters = ['😈','🎃','👹','🦂','👺','🦇','👾','👽']
    def monsters = ['&#x1f608;','&#x1f383;','&#x1f479;','&#x1f982;','&#x1f47a;','&#x1f987;','&#x1f47e;','&#x1f47d;']
    def deadmonsters = ['&#x1f480;']; // '☠'
    def pit = false
    def pitreport = new File ("build/reports/pitest/mutations.xml")
    def killdeMutants = []

    if (pitreport.exists()) {
        pit = true
        pitreport = new XmlSlurper().parse(pitreport)

        def convertToMap = { nodes ->
            nodes.children().collect { node ->
                node.attributes() +
                        node.children().collectEntries {
                            [it.name(), it.text()]
                        }
            }
        }
        pitreport = convertToMap(pitreport)
        killedMutants = pitreport.findAll { it.status=="KILLED" }
        System.out.println killedMutants
    }
// prepare some figures
    def mutatedClasses = pitreport.collect { it.mutatedClass }.unique()
    def mutatedPackages = mutatedClasses.collect { it.split("[.]")[0..-2].join(".") }.unique()
    def mutants = pitreport.size()
    def killedMutants = pitreport.findAll { it.status=="KILLED" }.size()
    Integer ratioKilled = killedMutants/mutants*100
%>

//add some additional styles which make the test-report a bit nicer
++++
<style>
    div.PASS {
        background-color: #DFD;
    }
    div.PASS {
        transition: max-height 300ms ease-out;
        max-height: 800px;
        overflow: hidden;
    }
    div.collapsed {
        max-height: 24px;
        padding-top: 2px;
        padding-bottom: 2px;
        overflow: hidden;
        cursor: pointer;
    }
    div.PASS.collapsed:before {
        content: '🔽 show passed test';
        width: 100%;
        text-align: center;
        display: block;
        font-family: Tahoma, arial, sans-serif;
        font-size: small;
    }
    div.PASS:before {
        content: '🔼 hide passed test';
        width: 100%;
        text-align: center;
        display: block;
        font-family: Tahoma, arial, sans-serif;
        font-size: small;
    }
    div.PASS pre {
        background-color: #EFE !important;
    }
    a.PASS {
        color: #080;
    }
    div.FAIL, div.ERROR, div.FAILURE {
        background-color: #FDD;
        border: 2px solid red;
    }
    a.FAIL, a.ERROR, a.FAILURE {
        color: #A00;
    }
    div.FAIL pre, div.ERROR pre, div.FAILURE pre {
        background-color: #FEE !important;
    }
    div.IGNORED {
        background-color: #DDD;
        border: none;
        color: #AAA;
    }
    a.IGNORED {
        color: #AAA;
    }
    div.PASS p, div.FAIL p, div.IGNORED p, div.ERROR p, div.FAILURE p {
        margin: 0;
    }
    div.PASS p, div.FAIL p, div.IGNORED p, div.ERROR p, div.FAILURE p {
        margin: 0;
    }
    div.PASS, div.FAIL, div.IGNORED, div.ERROR, div.FAILURE {
        padding: 3px 5px;
    }
    div.PASS pre, div.FAIL pre, div.IGNORED pre, div.ERROR pre, div.FAILURE pre {
        padding: 3px 5px !important;
        margin: 0 0 0 15px !important;
    }
    div.PASS div.listingblock, div.FAIL div.listingblock, div.IGNORED div.listingblock div.ERROR div.listingblock div.FAILURE div.listingblock {
        margin: 0;
    }
    div.PASS div.imageblock, div.FAIL div.imageblock, div.IGNORED div.imageblock, div.ERROR div.imageblock, div.FAILURE div.imageblock {
        margin: 0;
    }
    div.PASS table, div.FAIL table, div.IGNORED table, div.ERROR table, div.FAILURE table {
        margin: 0 !important;
    }
    div.PASS td, div.FAIL td, div.IGNORED td, div.ERROR td, div.FAILURE td {
        padding: 2px 6px;
    }
    div.PASS th, div.FAIL th, div.IGNORED th, div.ERROR th, div.FAILURE th {
        padding: 2px 6px;
    }

</style>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // re-style TOC
        var tocLabels = document.querySelectorAll('#toc a');

        tocLabels.forEach(label => {
            if (label.text.includes("IGNORED:")) {
                label.classList.add('IGNORED');
            };
            if (label.text.includes("FAIL:")) {
                label.classList.add('FAIL');
            };
            if (label.text.includes("FAILURE:")) {
                label.classList.add('FAIL');
            };
            if (label.text.includes("ERROR:")) {
                label.classList.add('FAIL');
            };
            if (label.text.includes("PASS:")) {
                label.classList.add('PASS');
            };
        });

        // collapse passed tests
        var passedTests = document.querySelectorAll('div.PASS');
        passedTests.forEach(test => {
            test.classList.add('collapsed');
            test.addEventListener("click", function(){ this.classList.toggle('collapsed'); }, false);
        })

    });
</script>

++++

// numbering from here on
:numbered:

<% try { %>

<% def stats = com.athaydes.spockframework.report.util.Utils.aggregateStats( data ) %>

== Specification run results

=== Specifications summary

[small]#created on ${new Date()} by ${System.properties['user.name']}#

.summary
[options="header"]
|===
| Total          | Passed          | Failed          | Feature failures | Feature errors   | Success rate         | Total time (ms)
| ${stats.total} | ${stats.passed} | ${stats.failed} | ${stats.fFails}  | ${stats.fErrors} | ${stats.successRate*100}%| ${stats.time}
|===

=== Specifications

[options="header"]
|===================================================================
| Name  | Features | Failed | Errors | Skipped | Success rate | Time
<% data.each { name, map ->
    %>| $name | ${map.stats.totalRuns} | ${map.stats.failures} | ${map.stats.errors} | ${map.stats.skipped} | ${map.stats.successRate*100}% | ${map.stats.time}
<% } %>
|===================================================================

=== Pitest Coverage

[cols="1,10"]
|===
| #Classes   | Mutation Coverage
^| ${mutatedClasses.size()}
a| ${ratioKilled}%:
<%
    pitreport.eachWithIndex { mutation, i ->
        if (mutation.status=="KILLED") {
            out << deadmonsters[(Math.random()*1000)%deadmonsters.size()]
        } else {
        }
    }
    pitreport.eachWithIndex { mutation, i ->
        if (mutation.status=="KILLED") {
        } else {
            out << monsters[(Math.random()*1000)%monsters.size()]
        }
    }
%>
|===

=== Pitest Breakdown by Package

[cols="1,1,5"]
|===
|Name    |#Classes   |Mutation Coverage
<%
        mutatedPackages.each { p ->
            def numClasses = mutatedClasses.findAll { it.startsWith(p) }.size()
            out << "|$p |$numClasses |    ??\n"
        }
%>
|===


<% data.each { name, map -> %>

<<<<
//tag::${name.replaceAll('[^a-zA-Z0-9]','')}[]
include::${name}.adoc[]
//end::${name.replaceAll('[^a-zA-Z0-9]','')}[]

<% } %>

[small]#generated with ${com.athaydes.spockframework.report.SpockReportExtension.PROJECT_URL}[Athaydes Spock Reports]#

<% } catch (Exception e) { out << e } %>
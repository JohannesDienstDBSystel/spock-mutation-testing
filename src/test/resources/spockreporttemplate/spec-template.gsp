<%--
 * Copyright 2020 DB Systel GmbH
 * SPDX-License-Identifier: Apache-2.0
--%>

<% try { %>
<%
        //pitest
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
            killedMutants = pitreport.findAll { it. status=="KILLED" }
            System.out.println killedMutants
        }
%>
<%
    def fmt = new com.athaydes.spockframework.report.internal.StringFormatHelper()
    def file = data.info.pkg.replaceAll("[.]","/")+"/"+data.info.filename
    def classname = data.info.pkg+"."+data.info.filename
    def stats = com.athaydes.spockframework.report.util.Utils.stats( data )
    def gebUtils, gebReport, specReport
    def assignedArtifacts = []
    try {
        def c = Class.forName("com.aoe.gebspockreports.GebReportUtils")
        if(c) {
            gebUtils = c.newInstance()

            gebReport = gebUtils.readGebReport()
            specReport = gebReport.findSpecByLabel(utils.getSpecClassName(data))
        }
    } catch (Exception e) {
        //it seems that GebSpockReports is not installed
    }
%>== Report for ${data.info.description.className}

<%
def narrative = (data.info.narrative ?: '')
%>
${narrative}

=== Summary

[options="header",cols="6"]
|====
|Total Runs
|Success Rate
|Total time
|Failures
|Errors
|Skipped

|${stats.totalRuns}|${fmt.toPercentage(stats.successRate)} |${fmt.toTimeDuration(stats.time)} |${stats.failures} |${stats.errors} |${stats.skipped}
|====

<% if (pit) { %>
<%
        def mutantsKilled = killedMutants.findAll {
            it.killingTest.startsWith(
                    data.info.description.className
            )
        }
        def classesUnderTest = mutantsKilled.collect { it.mutatedClass }.unique()
        def mutantsSurvived = pitreport.findAll {
            (it.status != "KILLED") && (it.mutatedClass in classesUnderTest)
        }
        Integer ratioKilled = mutantsKilled.size()/pitreport.size()*100

%>
[options="header",cols="1,5"]
|====
| Classes
| Mutants killed
|${classesUnderTest?.size()}
| ${ratioKilled}%: <%mutantsKilled?.size().times{out << deadmonsters[(Math.random()*1000)%deadmonsters.size()]}%>
<%mutantsSurvived?.size().times{out << monsters[(Math.random()*1000)%monsters.size()]}%>
|====

classes under Test:

<%
classesUnderTest.each {
    //de.dbsystel.numbers/Fibonacci.java.html
    def sources = mutantsKilled.collect {it.sourceFile}.unique()
    sources.each { sourceFile ->
        out << "* link:../../../pitest/${it.split('[.]')[0..-2].join(".")}/${sourceFile}.html[$it]"
    }
}
%>
<% } %>

//{gitwebpath}${file}[${file}]

=== Features
<%
    def featureCount = 0

    features.eachFeature { name, result, blocks, iterations, params ->
        def isIgnored = result == 'IGNORED'
        featureCount += isIgnored ? 0 : 1
        def gebFeatureReport = specReport?.findFeatureByNumberAndName(featureCount, name)
        def gebArtifacts = gebFeatureReport?.artifacts
%>

==== $result: $name

<%
	def whyIgnored = description.getAnnotation(spock.lang.Ignore)?.value()
        out << (whyIgnored?:'')

%>

//feature start

//fail or success
[role="$result"]
****

//given, when, then blocks with code
<%
for ( block in blocks ) {
%>
${block.kind} **${block.text?:' - '}** +
<% if (block.sourceCode) { %>
[source, groovy]
----
${block.sourceCode.join('\n')}
----
<% } //if %>
<%
} // for
%>

//where-block as table
<%
    def executedIterations = iterations.findAll { it.dataValues || it.errors }
    if ( params && executedIterations ) {
 %>
[options="header"]
|====
| ${params.join( ' | ' )} |
<%
    for ( iteration in executedIterations ) {
%>| ${iteration.dataValues.join( ' | ' )} | ${iteration.errors ? '(FAIL)' : '(PASS)'}
<%  }
%>|====


<%  } // if %>



//error output
<%
        def problems = executedIterations.findAll { it.errors }
        if ( problems ) {
            out << "\n[IMPORTANT]\n.The following Error occured\n====\n"
            for ( badIteration in problems ) {
                if ( badIteration.dataValues ) {
                    out << '* ' << badIteration.dataValues << '\n'
                }
                for ( error in badIteration.errors ) {
                    out << '----\n' << error << '\n----\n'
                }
            }
            out << "====\n"
        }
 %>

<% if (gebArtifacts) { %>
 +

.Screenshots:
[cols="a,a,a,a"]
|====

<% gebArtifacts.sort { it.number }.eachWithIndex { artifact, i ->
        assignedArtifacts << artifact
        def label = artifact.label?.replaceFirst(name+"-", '')
        def trCssClass = label.endsWith('-failure') ? 'geb-failure' : ''
        def imageFile = "./" + artifact.files.find { it.endsWith('png') }
        def domSnapshotFile = "./" + artifact.files.find { it.endsWith('html') }
        %>
|
.${label}
image::${imageFile.replaceAll(" ","%20").replaceAll('\\\\','/')}[screenshot $label]
//link:${domSnapshotFile.replaceAll(" ","%20")}[$label]
        <%
        }
//fill remaining cells
(gebArtifacts.size()%4).times {
     out << "| \r\n"
}
%>
|====
<% } //if (gebArtifacts)%>

****

//next feature
 <%
    }
 %>

<%
    def unassignedArtifacts = specReport?.getUnassignedGebArtifacts()
    if (unassignedArtifacts) {
        unassignedArtifacts -= assignedArtifacts
    }
    if (unassignedArtifacts) {
%>

== Unassigned Screenshots

The following Screenshots could not be mapped to a feature.

[role="unassignedArtifacts"]
****

|===
| Label | Image | Html| Page object
    <% unassignedArtifacts.forEach { artifact ->
        def label = artifact.label
        def imageFile = "./" + artifact.files.find { it.endsWith('png') }
        def domSnapshotFile = "./" + artifact.files.find { it.endsWith('html') }
    %>
| $label| $imageFile | ${artifact.pageObject}

        <%
                } %>
|===

****

<% } %>
<% } catch (Exception e) { out << e } %>
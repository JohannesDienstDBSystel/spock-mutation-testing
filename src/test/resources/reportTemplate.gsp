<%--
 * Copyright 2020 DB Systel GmbH
 * SPDX-License-Identifier: Apache-2.0
--%>

<%
// prepare some figures
def mutatedClasses = report.collect { it.mutatedClass }.unique()
def mutatedPackages = mutatedClasses.collect { it.split("[.]")[0..-2].join(".") }.unique()
def mutants = report.size()
def killedMutants = report.findAll { it.status=="KILLED" }.size()
Integer ratioKilled = killedMutants/mutants*100

%>
== Pit Test Coverage Report

=== Project Summary

|===
| Number of Classes    | Line Coverage    | Mutation Coverage
| ${mutatedClasses.size()}
| 46% 27/59
| ${ratioKilled}% ${killedMutants}/${report.size}
|===

=== Breakdown by Package

|===
|Name    |Number of Classes    |Line Coverage    |Mutation Coverage
<%
mutatedPackages.each { p ->
    def numClasses = mutatedClasses.findAll { it.startsWith(p) }.size()
    out << "|$p |$numClasses |? |    ??\n"
}
%>
|===

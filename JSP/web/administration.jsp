<%-- 
    Document   : administration
    Created on : 29-Mar-2008, 21:50:44
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Live Fencing Administration</title>
    </head>
    <body>
        <jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
        <table border="1">
            <tr>  
                <c:set var="numCols" value="0" />
                <c:forEach items="${tourn.competitions}" var="comp">
                    <c:if test="${!(empty comp)}">
                        <c:set var="numCols" value="${numCols+1}" />
                        <td><c:url value="changecomp.jsp" var="changeCompURL" scope="page"/>
                            <form action="${changeCompURL}" method="post">
                                <input type="hidden" value="${numCols - 1}" name="compIndex" />
                                <table>
                                    <tr style="background-color: ${comp.colour}">
                                        <td>Name:</td>
                                        <td>${comp.name}</td>
                                    </tr>
                                    <tr>
                                        <td>Short Name:</td>
                                        <td>${comp.shortName}</td>
                                    </tr>
                                    <tr>
                                        <td>Engarde File:</td>
                                        <td><input type="text" name="engardeFile" value="${comp.engardeFile}" /></td>
                                    </tr>
                                    <tr>
                                        <td>Colour:</td>
                                        <td><input type="text" name="colour" value="${comp.colour}" /></td>
                                    </tr>
                                    <tr><td><input type="submit" name="update" value="Update" /><td><input type="submit" name="remove" value="Remove" /></td></tr>
                                </table>
                            </form>
                        </td>
                    </c:if>
                </c:forEach>
                <td> <c:url value="newcomp.jsp" var="newCompURL" scope="page"/>
                    <form action="${newCompURL}" method="post">
                        <table>
                            <tr>
                                <td>Engarde File:</td>
                                <td><input type="text" name="engardeFile" value="<new file>" /></td>
                            </tr>
                            <tr>
                                <td>Colour:</td>
                                <td><input type="text" name="colour" value="${comp.colour}" /></td>
                            </tr>
                            <tr><td colspan="2"><input type="submit" value="Add competition" /></td></tr>
                        </table>
                    </form>
                </td>
            </tr>
            <c:set var="dispIndex" value="0" />
            <c:forEach items="${tourn.displaySeries}" var="dispSeries">
                <c:if test="${!(empty dispSeries)}">
                    <c:set var="isEnabled" value="" />
                    <c:set var="tableauPresent" value="" />
                <tr>
                    <c:set var="viewIndex" value="0" />
                    <c:forEach items="${tourn.displaySeries[dispIndex].views}" var="view" >
                        <td><c:url value="changeseries.jsp" var="changeSeriesURL" scope="page"/>
                            <form action="${changeSeriesURL}" method="post" >
                                <input type="hidden" value="${dispIndex}" name="seriesIndex" />
                                <input type="hidden" value="${viewIndex}" name="viewIndex" />
                                <table>
                                <tr><c:if test="${view.enabled}"><c:set var="isEnabled" value="checked=\"checked\"" /></c:if>
                                    <td><input type="checkbox" name="enabled" ${isEnabled} />Enabled</td>
                                </tr>
                                <tr>
                                    <td>
                                        List type:
                                    </td>
                                    <td>
                                        <select name="type" >
                                            <option value="none" <c:if test="${view.type == 'none'}"> selected="selected"</c:if> >None</option>
                                            <option value="entry" <c:if test="${view.type == 'entry'}"> selected="selected"</c:if> >Entry</option>
                                            <option value="seeding" <c:if test="${view.type == 'seeding'}"> selected="selected"</c:if> >Seeding</option>
                                            <option value="result" <c:if test="${view.type == 'result'}"> selected="selected"</c:if> >Result</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        Tableau Prefix:
                                    </td>
                                    <c:if test="${view.tableau}"><c:set var="tableauPresent" value="checked=\"checked\"" /></c:if>
                                    <td>
                                        <select name="tableau" >
                                            <option value="none" <c:if test="${view.type == 'none'}"> selected="selected"</c:if> >None</option>
                                            <c:forEach var="tab" items="${view.competition.tableaus}" >
                                            <option value="${tab.name}" <c:if test="${view.tableau eq tab.name}"> selected="selected"</c:if> >Tableau ${tab.name}</option>
                                            </c:forEach>
                                        </select></td>
                                </tr>
                                <tr>
                                    <td><input type="submit" value="Update" /></td>
                                </tr>
                                </table>
                            </form>
                        </td>
                        <c:set var="viewIndex" value="${viewIndex + 1}" />
                    </c:forEach>
                    <td>
                        <table>
                            <tr><th>Series Name: <b>${dispSeries.name}</b></th>
                            <c:forEach items="${dispSeries.sessions}" var="sess">
                                <c:if test="${!(empty sess)}">
                                    <tr><td>${sess}</td></tr>
                                </c:if>
                            </c:forEach>
                        </table>
                    </td>
                </tr>
                </c:if>
                <c:set var="dispIndex" value="${dispIndex + 1}" />
             </c:forEach>
            <tr>
                <td colspan="${numCols}"><c:url value="newseries.jsp" var="newSeriesURL" scope="page"/>
                    <form action="${newSeriesURL}" method="post">
                        <table> 
                            <tr>
                                <td>Series Name:</td>
                                <td><input type="text" name="name" value="<series name>" /></td>
                            </tr>
                            <tr><td colspan="2"><input type="submit" value="Add display series" /></td></tr>
                        </table>
                    </form>
                </td>
            </tr>
        </table>
    <br/>
    <hr/>
    <br/>
    <c:url value="changesettings.jsp" var="changeSettingsURL" scope="page"/>
    <form action="${changeSettingsURL}" method="post">
    <table>
        <tr>
        <td>Path to Perl exe</td><td><input type="text" name="perlExePath" value="${tourn.perlExePath}" /></td>
        </tr><tr>
        <td>Path to writetoxml.pl file</td><td><input type="text" name="perlFilePath" value="${tourn.perlFilePath}" /></td>
        <tr><td colspan="2"<input type="submit" value="Update Path Settings" /></td></tr>
    </table>
    </form>
</body>
</html>

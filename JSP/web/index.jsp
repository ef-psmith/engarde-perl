<%-- 
    Document   : index
    Created on : 28-Mar-2008, 21:12:24
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <table>
            <tr><td>
                <c:url value="view.jsp" var="viewPage" scope="page" />
                <form action="${viewPage}" method="get">
                    <table>
                        <tr>
                            <td>Session Name:</td>
                            <td><input type="text" name="sessionName" /></td>
                        </tr>
                        <tr><td colspan="2">
                            <select name="seriesName">
                                <c:forEach items="${tourn.displaySeries}" var="disp">
                                    <option value="${disp.name}">${disp.name}</option>
                                </c:forEach>
                            </select>
                        </td></tr>
                        <tr>
                            <td colspan="2"><input type="submit" value="Start" /></td>
                        </tr>
                    </table>
                </form>
            </td></tr>
                    
            <tr><td><a href="tableau.jsp">Tableau</a></td></tr>
            <tr><td><a href="administration.jsp">Admin</a></td></tr>
        </table>
    </body>
</html>

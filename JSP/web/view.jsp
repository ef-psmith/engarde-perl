<%-- 
    Document   : view
    Created on : 08-Apr-2008, 21:47:48
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>


<jsp:useBean id="dispIter" class="LiveFencing.DisplaySeriesIterator" scope="session" />
<c:if test="${!(empty param.seriesName)}">
    <jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
    <jsp:setProperty name="dispIter" property="sessionName" value="${param.sessionName}" />
    ${lfo:setTournOnDispSeriesIter(dispIter,tourn,param.seriesName)}
</c:if>
<c:choose>
    <c:when test="${empty dispIter.nextView}">
        
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        
        <meta http-equiv="refresh" content="83;url=view.jsp" />
    </head>
    <body>
        <h2>No views to display</h2>
    </body>
</html>
    </c:when>
    
    <c:when test="${dispIter.currentView.type ne 'none' && dispIter.currentView.tableau eq 'none'}" >
        
        <c:url value="list.jsp" var="listPage" scope="page" />
        <jsp:forward page="${listPage}" />
    </c:when>
    <c:when test="${dispIter.currentView.type eq 'none' && dispIter.currentView.tableau ne 'none'}" >
        
        <c:url value="tableau.jsp" var="tabPage" scope="page" />
        <jsp:forward page="${tabPage}" />
    </c:when>
    <c:otherwise>
            
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        
        <meta http-equiv="refresh" content="83;url=view.jsp" />
    </head>
    <body>
        <h2>Not sure which view to display</h2>
    </body>
</html>
    </c:otherwise>
    
</c:choose> 

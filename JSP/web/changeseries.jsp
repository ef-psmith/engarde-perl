<%-- 
    Document   : changeSeries
    Created on : 04-Apr-2008, 20:15:37
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>

<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
<c:set var="series" value="${tourn.displaySeries[param.seriesIndex]}" scope="page" />
<c:set var="view" value="${series.views[param.viewIndex]}" scope="page" />
<jsp:setProperty name="view" property="enabled" value="false"/>
<jsp:setProperty name="view" property="type"  value="none"/>
<jsp:setProperty name="view" property="tableau" value="false" />

<jsp:setProperty name="view" property="enabled" />
<jsp:setProperty name="view" property="type" />
<jsp:setProperty name="view" property="tableau" />

<c:url value="administration.jsp" var="adminPage" scope="page" />
<c:redirect url="${adminPage}" />

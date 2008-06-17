<%-- 
    Document   : changesettings
    Created on : 17-Jun-2008, 22:29:05
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>

<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />

<jsp:setProperty name="tourn" property="*" />

<c:url value="administration.jsp" var="adminPage" scope="page" />
<c:redirect url="${adminPage}" />

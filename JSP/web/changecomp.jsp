<%-- 
    Document   : changeComp
    Created on : 04-Apr-2008, 21:18:31
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>

<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />

<c:set var="comp" value="${tourn.competitions[param.compIndex]}" scope="page" />
<jsp:setProperty name="comp" property="engardeFile" />
<jsp:setProperty name="comp" property="colour" />

<c:url value="administration.jsp" var="adminPage" scope="page" />
<c:redirect url="${adminPage}" />

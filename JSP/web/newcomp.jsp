<%-- 
    Document   : newComp
    Created on : 03-Apr-2008, 20:16:47
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>

<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
<jsp:useBean id="newcomp" class="LiveFencing.Competition" scope="page" />
<jsp:setProperty name="newcomp" property="engardeFile" value="${param.engardeFile}" />
<jsp:setProperty name="newcomp" property="colour" value="${param.colour}" />
${lfo:setTournOnComp(newcomp,tourn)}

<c:url value="administration.jsp" var="adminPage" scope="page" />
<c:redirect url="${adminPage}" />
<%-- 
    Document   : newSeries
    Created on : 03-Apr-2008, 21:11:48
    Author     : Oliver
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>

<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
<jsp:useBean id="newseries" class="LiveFencing.DisplaySeries" scope="page" />
<jsp:setProperty name="newseries" property="*" />
${lfo:setTournOnDispSeries(newseries,tourn)}

<c:url value="administration.jsp" var="adminPage" scope="page" />
<c:redirect url="${adminPage}" />

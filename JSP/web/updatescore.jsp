<%-- 
    Document   : updatescore
    Created on : 21-May-2008, 16:36:54
    Author     : Oliver
--%>

<%@page contentType="text/xml" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>
<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
${lfo:updatescore(tourn, param.comp, param.tableau, param.round,param.match,param.scorea,param.scoreb,param.timeremaining)}





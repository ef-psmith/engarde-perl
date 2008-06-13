<%-- 
    Document   : setwinner
    Created on : 29-May-2008, 22:39:36
    Author     : Oliver
--%>


<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>
<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
${lfo:setwinner(tourn, param.comp, param.tableau, param.round,param.match,param.winnerid)}


<%-- 
    Document   : nextbouts
    Created on : 20-May-2008, 20:00:06
    Author     : Oliver
--%>

<%@page contentType="text/xml" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lfo" uri="/WEB-INF/tlds/LiveFencingObjects" %>
<jsp:useBean id="tourn" class="LiveFencing.Tournament" scope="application" />
<c:set var="piste" value="${param.piste}" scope="page" />

<bouts>
<c:set var="ordinal" value="0" scope="page" />
<c:forEach items="${lfo:bouts(tourn,piste)}" var="bout">
    <c:set var="ordinal" value="${ordinal + 1}" scope="page" />
    <bout order="${ordinal}" comp="${bout.competition}" compkey="${bout.competitionKey}" tableau="${bout.tableau}" round="${bout.round}" match="${bout.match}" state="${bout.state}" >
        <fencer_a club="${bout.fencerA_Club}" fencer_id="${bout.fencerA_ID}">${bout.fencerA_Name}</fencer_a>
        <fencer_b club="${bout.fencerB_Club}" fencer_id="${bout.fencerB_ID}">${bout.fencerB_Name}</fencer_b>
    </bout>
</c:forEach>
</bouts>

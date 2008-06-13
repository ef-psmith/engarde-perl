<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<link href="css/tableau_style.css" rel="stylesheet" type="text/css" media="screen" />
<link href="css/vlist.css" rel="stylesheet" type="text/css" media="screen" />
<link href="css/fencer_list.css" rel="stylesheet" type="text/css" media="screen" />
<script type="text/javascript">
	onerror=handleErr
	function handleErr(msg,url,l) {
		alert(msg);
		//Handle the error here
		return true;
	}

	function onPageLoaded() {
		onPauseTimer();
	}
	var top = 0;
        var pageStartTop=0;
	function onPauseTimer() {
            pageStartTop = top;
            t1=setTimeout("onScrollTimer()",3000);
	}

	function onScrollTimer() {
            var topVal = top + 'em';
            document.getElementById("vert_list_id").style.top = topVal;
            top -= 0.5;
            if (top <= pageStartTop - 10) {
                onPauseTimer();
            } else {
                t2=setTimeout("onScrollTimer()",50);
            }
	}

</script>

<meta http-equiv="refresh" content="83;url=entry.html">
</head>
<body onload="onPageLoaded()">
<title>Men's Foil</title>

<div class="vert_list_container">
	<h2 class="list_title">Result</h2>
	<div class="list_header">
		<table>
			<tr>
				<td class="position">Position</td>
				<td class="fencer_name">Fencer</td>
				<td class="fencer_club">Club</td>
			</tr>
		</table>
	</div>
	<div class="list_body">
		<table class="list_table" id="vert_list_id">
			<tr>
				<td class="position">1</td>
				<td class="fencer_name">MANSOUR David</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">2</td>
				<td class="fencer_name">BEEVERS James</td>
				<td class="fencer_club">CYRANO</td>
			</tr>
			<tr>
				<td class="position">3=</td>
				<td class="fencer_name">RISELEY David</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">3=</td>
				<td class="fencer_name">COOK Keith</td>
				<td class="fencer_club">EDINBURGH</td>
			</tr>
			<tr>
				<td class="position">5</td>
				<td class="fencer_name">ROWE James</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">6</td>
				<td class="fencer_name">BEEVERS Andrew</td>
				<td class="fencer_club">CYRANO</td>
			</tr>
			<tr>
				<td class="position">7</td>
				<td class="fencer_name">BENGRY Marc</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">8</td>
				<td class="fencer_name">BARNETT Michael</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">9</td>
				<td class="fencer_name">ROBINSON Daniel</td>
				<td class="fencer_club">SOUTHERN MARCHES</td>
			</tr>
			<tr>
				<td class="position">10</td>
				<td class="fencer_name">MELIA Rhys</td>
				<td class="fencer_club">GWENT SWORD</td>
			</tr>
			<tr>
				<td class="position">11</td>
				<td class="fencer_name">BELL Nick</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">12</td>
				<td class="fencer_name">KENBER Jamie</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">13</td>
				<td class="fencer_name">DOOTSON Nick</td>
				<td class="fencer_club">MANCHESTER</td>
			</tr>
			<tr>
				<td class="position">14</td>
				<td class="fencer_name">ROSOWSKY Yasin</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">15</td>
				<td class="fencer_name">DAVIS James</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">16</td>
				<td class="fencer_name">BARWELL Peter</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">17</td>
				<td class="fencer_name">BASHIR Karim</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">18</td>
				<td class="fencer_name">FITZGERALD Jamie</td>
				<td class="fencer_club">WEST FIFE</td>
			</tr>
			<tr>
				<td class="position">19</td>
				<td class="fencer_name">MEPSTEAD Marcus</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">20</td>
				<td class="fencer_name">MACINNES Alex</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">21</td>
				<td class="fencer_name">ROSOWSKY Husayn</td>
				<td class="fencer_club">SALLE KISS</td>
			</tr>
			<tr>
				<td class="position">22</td>
				<td class="fencer_name">PEGGS Ben</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">23</td>
				<td class="fencer_name">JEFFERIES Edward</td>
				<td class="fencer_club">DINGWALL</td>
			</tr>
			<tr>
				<td class="position">24</td>
				<td class="fencer_name">ABIDOGUN Kola</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">25</td>
				<td class="fencer_name">BRADLEY Blaise</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">26</td>
				<td class="fencer_name">STOCKLEY Sam</td>
				<td class="fencer_club">WORCESTER</td>
			</tr>
			<tr>
				<td class="position">27</td>
				<td class="fencer_name">POTTERTON Tom</td>
				<td class="fencer_club">BRISTOL GRAMMAR</td>
			</tr>
			<tr>
				<td class="position">28</td>
				<td class="fencer_name">GRAHAME Kenneth</td>
				<td class="fencer_club">QUEENS UNIV BELFAST</td>
			</tr>
			<tr>
				<td class="position">29</td>
				<td class="fencer_name">ALEXANDER David</td>
				<td class="fencer_club">LOUGHBOROUGH</td>
			</tr>
			<tr>
				<td class="position">30</td>
				<td class="fencer_name">MEPSTEAD Alex</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">31</td>
				<td class="fencer_name">WOOD Adam</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">32</td>
				<td class="fencer_name">BECK Corin</td>
				<td class="fencer_club">MANCHESTER</td>
			</tr>
			<tr>
				<td class="position">33</td>
				<td class="fencer_name">BROOKE Alistair</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">34</td>
				<td class="fencer_name">LANGRIDGE-BROWN Joseph</td>
				<td class="fencer_club">CYRANO</td>
			</tr>
			<tr>
				<td class="position">35</td>
				<td class="fencer_name">COTT Martin</td>
				<td class="fencer_club">BATH SWORD</td>
			</tr>
			<tr>
				<td class="position">36</td>
				<td class="fencer_name">SHAH Leon</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">37</td>
				<td class="fencer_name">ALLEN Richard</td>
				<td class="fencer_club">CADS</td>
			</tr>
			<tr>
				<td class="position">38</td>
				<td class="fencer_name">ADEBO Anthony</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">39</td>
				<td class="fencer_name">RANDALL Daniel</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">40</td>
				<td class="fencer_name">ARRON Louis</td>
				<td class="fencer_club">BRISTOL GRAMMAR</td>
			</tr>
			<tr>
				<td class="position">41</td>
				<td class="fencer_name">DAVIS Paul</td>
				<td class="fencer_club">ST ALBANS</td>
			</tr>
			<tr>
				<td class="position">42</td>
				<td class="fencer_name">ROWCLIFFE Tris</td>
				<td class="fencer_club">BRISTOL GRAMMAR</td>
			</tr>
			<tr>
				<td class="position">43</td>
				<td class="fencer_name">WIGGINS David</td>
				<td class="fencer_club">LEOMINSTER</td>
			</tr>
			<tr>
				<td class="position">44</td>
				<td class="fencer_name">DELANEY Pascal</td>
				<td class="fencer_club">CAMBRIDGE SWORD</td>
			</tr>
			<tr>
				<td class="position">45</td>
				<td class="fencer_name">SUTTON Mark</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">46</td>
				<td class="fencer_name">SACHARIEW Nikola</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">47</td>
				<td class="fencer_name">SUMMERBELL Daniel</td>
				<td class="fencer_club">BRISTOL GRAMMAR</td>
			</tr>
			<tr>
				<td class="position">48</td>
				<td class="fencer_name">LOCKWOOD John</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">49</td>
				<td class="fencer_name">WRIGHT Philip</td>
				<td class="fencer_club">BRISTOL UNIV</td>
			</tr>
			<tr>
				<td class="position">50</td>
				<td class="fencer_name">TURNER Martin</td>
				<td class="fencer_club">SUTTON COLDFIELD</td>
			</tr>
			<tr>
				<td class="position">51</td>
				<td class="fencer_name">SCOURFIELD Jason</td>
				<td class="fencer_club">PEMBROKESHIRE</td>
			</tr>
			<tr>
				<td class="position">52</td>
				<td class="fencer_name">HYNDMAN Donald</td>
				<td class="fencer_club">CAMBRIDGE SWORD</td>
			</tr>
			<tr>
				<td class="position">53</td>
				<td class="fencer_name">WALSH Patrick</td>
				<td class="fencer_club">BRISTOL GRAMMAR</td>
			</tr>
			<tr>
				<td class="position">54</td>
				<td class="fencer_name">MACKENZIE Matt</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">55</td>
				<td class="fencer_name">CHANG Dominic</td>
				<td class="fencer_club">BATH SWORD</td>
			</tr>
			<tr>
				<td class="position">56</td>
				<td class="fencer_name">PINTO Roberto</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">57</td>
				<td class="fencer_name">ALLEN Thomas</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">58</td>
				<td class="fencer_name">BIGGS Richard</td>
				<td class="fencer_club">SWAY</td>
			</tr>
			<tr>
				<td class="position">59</td>
				<td class="fencer_name">KASTNER Philip</td>
				<td class="fencer_club">CYRANO</td>
			</tr>
			<tr>
				<td class="position">60</td>
				<td class="fencer_name">GORDON Douglas</td>
				<td class="fencer_club">SALLE BOSTON</td>
			</tr>
			<tr>
				<td class="position">61</td>
				<td class="fencer_name">ROWLES Tom</td>
				<td class="fencer_club">SUSSEX HOUSE</td>
			</tr>
			<tr>
				<td class="position">62</td>
				<td class="fencer_name">HOLDER Peter</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">63</td>
				<td class="fencer_name">CONYARD Anthony</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">64</td>
				<td class="fencer_name">O'DONNELL Callum</td>
				<td class="fencer_club">WEST FIFE</td>
			</tr>
			<tr>
				<td class="position">65</td>
				<td class="fencer_name">ROSOWSKY Ahmed</td>
				<td class="fencer_club">SALLE KISS</td>
			</tr>
			<tr>
				<td class="position">66</td>
				<td class="fencer_name">BURNEY Julian</td>
				<td class="fencer_club">U/A</td>
			</tr>
			<tr>
				<td class="position">67</td>
				<td class="fencer_name">LOGGIE James</td>
				<td class="fencer_club">ST ANDREWS UNIV</td>
			</tr>
			<tr>
				<td class="position">68</td>
				<td class="fencer_name">FORBES Chris</td>
				<td class="fencer_club">A & C</td>
			</tr>
			<tr>
				<td class="position">69</td>
				<td class="fencer_name">OAKLEY Mark</td>
				<td class="fencer_club">NOTTINGHAM CAVALIERS</td>
			</tr>
			<tr>
				<td class="position">70</td>
				<td class="fencer_name">DARROUX Steve</td>
				<td class="fencer_club">SALLE MICHAEL JOSEPH</td>
			</tr>
			<tr>
				<td class="position">71</td>
				<td class="fencer_name">THURSTON Dan</td>
				<td class="fencer_club">AFFONDO</td>
			</tr>
			<tr>
				<td class="position">72</td>
				<td class="fencer_name">DUDETSKY Edward</td>
				<td class="fencer_club">SALLE ZINA</td>
			</tr>
			<tr>
				<td class="position">73</td>
				<td class="fencer_name">TARLING Steven</td>
				<td class="fencer_club">MANCHESTER</td>
			</tr>
			<tr>
				<td class="position">74</td>
				<td class="fencer_name">MAKUCEWICZ Alek</td>
				<td class="fencer_club">ALDERSHOT</td>
			</tr>
			<tr>
				<td class="position">75</td>
				<td class="fencer_name">HENDRIE Thomas</td>
				<td class="fencer_club">ONE TWO SIX</td>
			</tr>
			<tr>
				<td class="position">76</td>
				<td class="fencer_name">BILLING Matthew</td>
				<td class="fencer_club">TRURO</td>
			</tr>
			<tr>
				<td class="position">77</td>
				<td class="fencer_name">THORNTON Graham</td>
				<td class="fencer_club">STOCKPORT</td>
			</tr>
			<tr>
				<td class="position">78</td>
				<td class="fencer_name">WYNN Tim</td>
				<td class="fencer_club">TRURO</td>
			</tr>
			<tr>
				<td class="position">79</td>
				<td class="fencer_name">WHEELER Stuart</td>
				<td class="fencer_club">WREXHAM</td>
			</tr>
			<tr>
				<td class="position">80</td>
				<td class="fencer_name">STANBRIDGE Paul</td>
				<td class="fencer_club">U/A</td>
			</tr>
			<tr>
				<td class="position">81</td>
				<td class="fencer_name">POWELL Matthew</td>
				<td class="fencer_club">SOLIHULL</td>
			</tr>
			<tr>
				<td class="position">82</td>
				<td class="fencer_name">COCKBURN Nick</td>
				<td class="fencer_club">SALLE PAUL</td>
			</tr>
			<tr>
				<td class="position">83</td>
				<td class="fencer_name">TUCKER Mark</td>
				<td class="fencer_club">CRAWLEY SWORD</td>
			</tr>
		</table>
	</div>
</div></body>

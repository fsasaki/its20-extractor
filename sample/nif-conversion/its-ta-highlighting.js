function showitsta () {
    var cssclass = document.createTextNode("*.itsta {background-color: #80FF80;}");
    var mystyle = document.createElement("style");
    mystyle.setAttribute('type','text/css');
    mystyle.appendChild(cssclass);
    myh = document.getElementsByTagName("head")[0];
    myh.appendChild(mystyle);
    var elems = document.getElementsByTagName('*');
for (i = 0; i < elems.length; i++) {
			currentel = elems[i];
			var annotationslist = "";
				if (currentel.getAttribute('its-ta-confidence')!= null) {
					var annotatorsref = document.getElementsByTagName("html")[0];
					var annotationtool = annotatorsref.getAttribute('its-annotators-ref');
					annotationslist = annotationslist + "\nEntity type / concept class: "
							+ currentel.getAttribute('its-ta-class-ref');
					annotationslist = annotationslist + "\nEntity / concept identifier: "
							+ currentel.getAttribute('its-ta-ident-ref');
					annotationslist = annotationslist + "\nText analysis confidence: "
							+ currentel.getAttribute('its-ta-confidence');
				}
							
							if (annotationslist.length > 1) {
				currentel.setAttribute('title', "ITS 2.0 Text Analysis Annotations found:\n"
				        + "Annotation tool: " + annotationtool.substring(14) + "\n"
						+ annotationslist);
				currentel.setAttribute('class', 'itsta');
			}
			}
		}
package org.daisy.pipeline.braille.pef.impl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.daisy.dotify.api.factory.FactoryProperties;
import org.daisy.dotify.api.table.TableProvider;
import org.daisy.pipeline.datatypes.DatatypeService;
import org.daisy.pipeline.datatypes.ValidationResult;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.w3c.dom.Document;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;

@Component(
	name = "org.daisy.pipeline.braille.pef.impl.TableDatatypeService",
	service = {
		DatatypeService.class
	}
)
public class TableDatatypeService extends DatatypeService {

	protected TableDatatypeService() {
		super("preview-table");
	}

	private Document xmlDefinition = null;
	private List<String> enumerationValues = null;
	// to expose all available tables we would use BrailleUtilsTableCatalog, but for now we only
	// present a list of languages
	private final LocaleBasedTableProvider catalog = new LocaleBasedTableProvider();

	@Reference(
		name = "TableProvider",
		unbind = "-",
		service = TableProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.STATIC
	)
	public void addTableProvider(TableProvider provider) {
		catalog.addTableProvider(provider);
	}

	public Document asDocument() throws Exception {
		if (xmlDefinition == null)
			createDatatype();
		return xmlDefinition;
	}

	public ValidationResult validate(String content) {
		if (enumerationValues == null)
			try {
				createDatatype();
			} catch (Exception e) {
				return ValidationResult.notValid("Failed to determine allowed values");
			}
		if (enumerationValues.contains(content))
			return ValidationResult.valid();
		else
			return ValidationResult.notValid("'" + content + "' is not in the list of allowed values.");
	}

	private void createDatatype() throws ParserConfigurationException, DOMException {
		Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder()
		                                     .getDOMImplementation().createDocument(null, "choice", null);
		List<String> values = new ArrayList<>();
		Element choice = doc.getDocumentElement();
		String defaultValue = "";
		values.add(defaultValue);
		choice.appendChild(doc.createElement("value"))
		      .appendChild(doc.createTextNode(defaultValue));
		choice.appendChild(doc.createElementNS("http://relaxng.org/ns/compatibility/annotations/1.0",
		                                       "documentation"))
		      .appendChild(doc.createTextNode("-"));
		List<FactoryProperties> tables = new ArrayList<>();
		catalog.init();
		tables.addAll(catalog.list());
		Collections.sort(tables,
		                 new Comparator<FactoryProperties>() {
				@Override
				public int compare(FactoryProperties o1, FactoryProperties o2) {
					String s1 = o1.getDisplayName();
					String s2 = o2.getDisplayName();
					if (s1 == null)
						if (s2 == null)
							return 0;
						else
							return -1;
					else if (s2 == null)
						return 1;
					else
						return s1.toLowerCase().compareTo(s2.toLowerCase()); }});
		for (FactoryProperties table : tables) {
			String value = "(id:\"" + table.getIdentifier() + "\")";
			values.add(value);
			choice.appendChild(doc.createElement("value"))
			      .appendChild(doc.createTextNode(value));
			String desc = table.getDisplayName();
			if (desc != null) {
				if (table.getDescription() != null && !"".equals(table.getDescription()))
					desc += ("\n" + table.getDescription());
				choice.appendChild(doc.createElementNS("http://relaxng.org/ns/compatibility/annotations/1.0",
				                                       "documentation"))
				      .appendChild(doc.createTextNode(desc));
			}
		}
		xmlDefinition = doc;
		enumerationValues = values;
	}
}

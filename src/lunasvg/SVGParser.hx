// Ported from lunasvg 3.5.0: source/svgparser.cpp
// Original code Copyright (c) 2020-2026 Samuel Ugochukwu, licensed under MIT.
// Modified: translated from C++ to Haxe. See LICENSE.
package lunasvg;

import lunasvg.SVGElement;
import lunasvg.SVGParserUtils;
import lunasvg.SVGParserUtils.SVGParserUtils.*;
import lunasvg.SVGProperty;

typedef Selector = Array<SimpleSelector>;

typedef SelectorList = Array<Selector>;

enum abstract MatchType(Int) from Int to Int {
    var None;
    var Equals;
    var Contains;
    var Includes;
    var StartsWith;
    var EndsWith;
    var DashEquals;
}

class AttributeSelector {

    public var matchType:MatchType = None;

    public var id:PropertyID = PropertyID.Unknown;

    public var value:String = "";

    public function new() {}

}

enum abstract PseudoClassType(Int) from Int to Int {
    var Unknown;
    var Empty;
    var Root;
    var Is;
    var Not;
    var FirstChild;
    var LastChild;
    var OnlyChild;
    var FirstOfType;
    var LastOfType;
    var OnlyOfType;
}

class PseudoClassSelector {

    public var type:PseudoClassType = Unknown;

    public var subSelectors:SelectorList = [];

    public function new() {}

}

enum abstract Combinator(Int) from Int to Int {
    var None;
    var Descendant;
    var Child;
    var DirectAdjacent;
    var InDirectAdjacent;
}

class SimpleSelector {

    public var combinator:Combinator = Descendant;

    public var id:ElementID = ElementID.Star;

    public var attributeSelectors:Array<AttributeSelector> = [];

    public var pseudoClassSelectors:Array<PseudoClassSelector> = [];

    public function new(combinator:Combinator) {
        this.combinator = combinator;
    }

}

class Declaration {

    public var specificity:Int = 0;

    public var id:PropertyID = PropertyID.Unknown;

    public var value:String = "";

    public function new() {}

}

typedef DeclarationList = Array<Declaration>;

class Rule {

    public var selectors:SelectorList = [];

    public var declarations:DeclarationList = [];

    public function new() {}

}

class RuleData {

    var m_selector:Selector;

    var m_declarations:DeclarationList;

    var m_specificity:Int;

    var m_position:Int;

    public function new(selector:Selector, declarations:DeclarationList, specificity:Int, position:Int) {
        m_selector = selector;
        m_declarations = declarations;
        m_specificity = specificity;
        m_position = position;
    }

    public function isLessThan(rule:RuleData):Bool {
        if (m_specificity != rule.m_specificity)
            return m_specificity < rule.m_specificity;
        return m_position < rule.m_position;
    }

    public inline function selector():Selector return m_selector;
    public inline function declarations():DeclarationList return m_declarations;
    public inline function specificity():Int return m_specificity;
    public inline function position():Int return m_position;

    public function match(element:SVGElement):Bool {
        return SVGParser.matchSelector(m_selector, element);
    }

}

typedef RuleDataList = Array<RuleData>;

/**
 * The XML parser, the CSS selector engine and the style sheet support of
 * lunasvg (svgparser.cpp). `Document.parse()` lives here as `parse()`.
 */
class SVGParser {

    static function equals(value:String, subvalue:String):Bool {
        return value == subvalue;
    }

    static function contains(value:String, subvalue:String):Bool {
        return value.indexOf(subvalue) >= 0;
    }

    static function includes(value:String, subvalue:String):Bool {
        if (subvalue.length == 0 || subvalue.length > value.length)
            return false;
        var input = new StringView(value);
        while (!input.empty()) {
            skipOptionalSpaces(input);
            var start = input.clone();
            while (!input.empty() && !IS_WS(input.front()))
                input.removePrefix(1);
            if (start.substr(0, start.length() - input.length()).equals(subvalue)) {
                return true;
            }
        }

        return false;
    }

    static function startswith(value:String, subvalue:String):Bool {
        if (subvalue.length == 0 || subvalue.length > value.length)
            return false;
        return StringTools.startsWith(value, subvalue);
    }

    static function endswith(value:String, subvalue:String):Bool {
        if (subvalue.length == 0 || subvalue.length > value.length)
            return false;
        return StringTools.endsWith(value, subvalue);
    }

    static function dashequals(value:String, subvalue:String):Bool {
        if (startswith(value, subvalue))
            return (value.length == subvalue.length || StringTools.fastCodeAt(value, subvalue.length) == '-'.code);
        return false;
    }

    static function matchAttributeSelector(selector:AttributeSelector, element:SVGElement):Bool {
        var value = element.getAttribute(selector.id);
        if (selector.matchType == MatchType.None)
            return value.length > 0;
        if (selector.matchType == MatchType.Equals)
            return equals(value, selector.value);
        if (selector.matchType == MatchType.Contains)
            return contains(value, selector.value);
        if (selector.matchType == MatchType.Includes)
            return includes(value, selector.value);
        if (selector.matchType == MatchType.StartsWith)
            return startswith(value, selector.value);
        if (selector.matchType == MatchType.EndsWith)
            return endswith(value, selector.value);
        if (selector.matchType == MatchType.DashEquals)
            return dashequals(value, selector.value);
        return false;
    }

    static function matchPseudoClassSelector(selector:PseudoClassSelector, element:SVGElement):Bool {
        if (selector.type == PseudoClassType.Empty)
            return element.children().length == 0;
        if (selector.type == PseudoClassType.Root)
            return element.isRootElement();
        if (selector.type == PseudoClassType.Is) {
            for (subSelector in selector.subSelectors) {
                for (simpleSelector in subSelector) {
                    if (!matchSimpleSelector(simpleSelector, element)) {
                        return false;
                    }
                }
            }

            return true;
        }

        if (selector.type == PseudoClassType.Not) {
            for (subSelector in selector.subSelectors) {
                for (simpleSelector in subSelector) {
                    if (matchSimpleSelector(simpleSelector, element)) {
                        return false;
                    }
                }
            }

            return true;
        }

        if (selector.type == PseudoClassType.FirstChild)
            return element.previousElement() == null;
        if (selector.type == PseudoClassType.LastChild)
            return element.nextElement() == null;
        if (selector.type == PseudoClassType.OnlyChild)
            return !(element.previousElement() != null || element.nextElement() != null);
        if (selector.type == PseudoClassType.FirstOfType) {
            var sibling = element.previousElement();
            while (sibling != null) {
                if (sibling.id() == element.id())
                    return false;
                sibling = sibling.previousElement();
            }

            return true;
        }

        if (selector.type == PseudoClassType.LastOfType) {
            var sibling = element.nextElement();
            while (sibling != null) {
                if (sibling.id() == element.id())
                    return false;
                sibling = sibling.nextElement();
            }

            return true;
        }

        return false;
    }

    static function matchSimpleSelector(selector:SimpleSelector, element:SVGElement):Bool {
        if (selector.id != ElementID.Star && selector.id != element.id())
            return false;
        for (sel in selector.attributeSelectors) {
            if (!matchAttributeSelector(sel, element)) {
                return false;
            }
        }

        for (sel in selector.pseudoClassSelectors) {
            if (!matchPseudoClassSelector(sel, element)) {
                return false;
            }
        }

        return true;
    }

    public static function matchSelector(selector:Selector, element:Null<SVGElement>):Bool {
        if (selector.length == 0)
            return false;
        var it = selector.length - 1;
        if (!matchSimpleSelector(selector[it], element)) {
            return false;
        }

        var combinator = selector[it].combinator;
        --it;

        while (it >= 0) {
            switch (combinator) {
                case Combinator.Child | Combinator.Descendant:
                    element = element.parentElement();
                case Combinator.DirectAdjacent | Combinator.InDirectAdjacent:
                    element = element.previousElement();
                case Combinator.None:
                    throw "unexpected combinator";
            }

            if (element == null)
                return false;
            if (matchSimpleSelector(selector[it], element)) {
                combinator = selector[it].combinator;
                --it;
            } else if (combinator != Combinator.Descendant && combinator != Combinator.InDirectAdjacent) {
                return false;
            }
        }

        return true;
    }

    static inline function IS_CSS_STARTNAMECHAR(c:Int):Bool {
        return IS_ALPHA(c) || c == '_'.code || c == '-'.code;
    }

    static inline function IS_CSS_NAMECHAR(c:Int):Bool {
        return IS_CSS_STARTNAMECHAR(c) || IS_NUM(c);
    }

    /**
     * `readCSSIdentifier()`: returns the identifier, or null.
     */
    static function readCSSIdentifier(input:StringView):Null<String> {
        if (input.empty() || !IS_CSS_STARTNAMECHAR(input.front()))
            return null;
        var start = input.pos;
        do {
            input.removePrefix(1);
        } while (!input.empty() && IS_CSS_NAMECHAR(input.front()));
        return input.data.substring(start, input.pos);
    }

    static function parseTagSelector(input:StringView, simpleSelector:SimpleSelector):Bool {
        if (skipDelimiter(input, '*'.code)) {
            simpleSelector.id = ElementID.Star;
            return true;
        }

        var name = readCSSIdentifier(input);
        if (name == null)
            return false;
        simpleSelector.id = SVGElement.elementid(name);
        return true;
    }

    static function parseIdSelector(input:StringView, simpleSelector:SimpleSelector):Bool {
        var a = new AttributeSelector();
        a.id = PropertyID.Id;
        a.matchType = MatchType.Equals;
        var value = readCSSIdentifier(input);
        if (value == null)
            return false;
        a.value = value;
        simpleSelector.attributeSelectors.push(a);
        return true;
    }

    static function parseClassSelector(input:StringView, simpleSelector:SimpleSelector):Bool {
        var a = new AttributeSelector();
        a.id = PropertyID.Class;
        a.matchType = MatchType.Includes;
        var value = readCSSIdentifier(input);
        if (value == null)
            return false;
        a.value = value;
        simpleSelector.attributeSelectors.push(a);
        return true;
    }

    static function parseAttributeSelector(input:StringView, simpleSelector:SimpleSelector):Bool {
        skipOptionalSpaces(input);
        var name = readCSSIdentifier(input);
        if (name == null)
            return false;
        var a = new AttributeSelector();
        a.id = PropertyIds.propertyid(name);
        a.matchType = MatchType.None;
        if (skipDelimiter(input, '='.code))
            a.matchType = MatchType.Equals;
        else if (skipString(input, "*="))
            a.matchType = MatchType.Contains;
        else if (skipString(input, "~="))
            a.matchType = MatchType.Includes;
        else if (skipString(input, "^="))
            a.matchType = MatchType.StartsWith;
        else if (skipString(input, "$="))
            a.matchType = MatchType.EndsWith;
        else if (skipString(input, "|="))
            a.matchType = MatchType.DashEquals;
        if (a.matchType != MatchType.None) {
            skipOptionalSpaces(input);
            var value = readCSSIdentifier(input);
            if (value != null) {
                a.value = value;
            } else {
                if (input.empty() || !(input.front() == '"'.code || input.front() == '\''.code))
                    return false;
                var quote = input.front();
                input.removePrefix(1);
                var n = input.findChar(quote);
                if (n < 0)
                    return false;
                a.value = input.substr(0, n).toString();
                input.removePrefix(n + 1);
            }
        }

        skipOptionalSpaces(input);
        if (!skipDelimiter(input, ']'.code))
            return false;
        simpleSelector.attributeSelectors.push(a);
        return true;
    }

    static function parsePseudoClassSelector(input:StringView, simpleSelector:SimpleSelector):Bool {
        var name = readCSSIdentifier(input);
        if (name == null)
            return false;
        var selector = new PseudoClassSelector();
        if (name == "empty")
            selector.type = PseudoClassType.Empty;
        else if (name == "root")
            selector.type = PseudoClassType.Root;
        else if (name == "not")
            selector.type = PseudoClassType.Not;
        else if (name == "first-child")
            selector.type = PseudoClassType.FirstChild;
        else if (name == "last-child")
            selector.type = PseudoClassType.LastChild;
        else if (name == "only-child")
            selector.type = PseudoClassType.OnlyChild;
        else if (name == "first-of-type")
            selector.type = PseudoClassType.FirstOfType;
        else if (name == "last-of-type")
            selector.type = PseudoClassType.LastOfType;
        else if (name == "only-of-type")
            selector.type = PseudoClassType.OnlyOfType;
        if (selector.type == PseudoClassType.Is || selector.type == PseudoClassType.Not) {
            skipOptionalSpaces(input);
            if (!skipDelimiter(input, '('.code))
                return false;
            skipOptionalSpaces(input);
            if (!parseSelectors(input, selector.subSelectors))
                return false;
            skipOptionalSpaces(input);
            if (!skipDelimiter(input, ')'.code)) {
                return false;
            }
        }

        simpleSelector.pseudoClassSelectors.push(selector);
        return true;
    }

    static var parseFailed:Bool = false;

    /**
     * `parseSimpleSelector(input, simpleSelector, failed)`: `failed` is
     * returned through `parseFailed`.
     */
    static function parseSimpleSelector(input:StringView, simpleSelector:SimpleSelector):Bool {
        var failed = false;
        var consumed = parseTagSelector(input, simpleSelector);
        do {
            if (skipDelimiter(input, '#'.code))
                failed = !parseIdSelector(input, simpleSelector);
            else if (skipDelimiter(input, '.'.code))
                failed = !parseClassSelector(input, simpleSelector);
            else if (skipDelimiter(input, '['.code))
                failed = !parseAttributeSelector(input, simpleSelector);
            else if (skipDelimiter(input, ':'.code))
                failed = !parsePseudoClassSelector(input, simpleSelector);
            else
                break;
            consumed = true;
        } while (!failed);
        parseFailed = failed;
        return consumed && !failed;
    }

    static var parsedCombinator:Combinator = None;

    static function parseCombinator(input:StringView):Bool {
        var combinator = Combinator.None;
        while (!input.empty() && IS_WS(input.front())) {
            combinator = Combinator.Descendant;
            input.removePrefix(1);
        }

        if (skipDelimiterAndOptionalSpaces(input, '>'.code))
            combinator = Combinator.Child;
        else if (skipDelimiterAndOptionalSpaces(input, '+'.code))
            combinator = Combinator.DirectAdjacent;
        else if (skipDelimiterAndOptionalSpaces(input, '~'.code))
            combinator = Combinator.InDirectAdjacent;
        parsedCombinator = combinator;
        return combinator != Combinator.None;
    }

    static function parseSelector(input:StringView, selector:Selector):Bool {
        var combinator = Combinator.None;
        do {
            var simpleSelector = new SimpleSelector(combinator);
            if (!parseSimpleSelector(input, simpleSelector))
                return !parseFailed && (combinator == Combinator.Descendant);
            selector.push(simpleSelector);
            var more = parseCombinator(input);
            combinator = parsedCombinator;
            if (!more)
                break;
        } while (true);
        return true;
    }

    static function parseSelectors(input:StringView, selectors:SelectorList):Bool {
        do {
            var selector:Selector = [];
            if (!parseSelector(input, selector))
                return false;
            selectors.push(selector);
        } while (skipDelimiterAndOptionalSpaces(input, ','.code));
        return true;
    }

    static function parseDeclarations(input:StringView, declarations:DeclarationList):Bool {
        if (!skipDelimiter(input, '{'.code))
            return false;
        skipOptionalSpaces(input);
        do {
            var name = readCSSIdentifier(input);
            if (name == null)
                return false;
            skipOptionalSpaces(input);
            if (!skipDelimiter(input, ':'.code))
                return false;
            skipOptionalSpaces(input);
            var value = input.clone();
            while (!input.empty() && !(input.front() == '!'.code || input.front() == ';'.code || input.front() == '}'.code))
                input.removePrefix(1);
            value.removeSuffix(input.length());
            stripTrailingSpaces(value);

            var declaration = new Declaration();
            declaration.specificity = 0x10;
            declaration.id = PropertyIds.csspropertyid(name);
            declaration.value = value.toString();
            if (skipDelimiter(input, '!'.code)) {
                skipOptionalSpaces(input);
                if (!skipString(input, "important"))
                    return false;
                declaration.specificity = 0x1000;
            }

            if (declaration.id != PropertyID.Unknown)
                declarations.push(declaration);
            skipOptionalSpacesOrDelimiter(input, ';'.code);
        } while (!input.empty() && input.front() != '}'.code);
        return skipDelimiter(input, '}'.code);
    }

    static function parseRule(input:StringView, rule:Rule):Bool {
        if (!parseSelectors(input, rule.selectors))
            return false;
        return parseDeclarations(input, rule.declarations);
    }

    static function parseStyleSheet(content:String):RuleDataList {
        var input = new StringView(content);
        var rules:RuleDataList = [];
        while (!input.empty()) {
            skipOptionalSpaces(input);
            if (skipDelimiter(input, '@'.code)) {
                var depth = 0;
                while (!input.empty()) {
                    var ch = input.front();
                    input.removePrefix(1);
                    if (ch == ';'.code && depth == 0)
                        break;
                    if (ch == '{'.code)
                        ++depth;
                    else if (ch == '}'.code && depth > 0) {
                        if (depth == 1)
                            break;
                        --depth;
                    }
                }

                continue;
            }

            var rule = new Rule();
            if (!parseRule(input, rule))
                break;
            for (selector in rule.selectors) {
                var specificity = 0;
                for (simpleSelector in selector) {
                    specificity += (simpleSelector.id == ElementID.Star) ? 0x0 : 0x1;
                    for (attributeSelector in simpleSelector.attributeSelectors)
                        specificity += (attributeSelector.id == PropertyID.Id) ? 0x10000 : 0x100;
                    specificity += simpleSelector.pseudoClassSelectors.length * 0x100;
                }

                rules.push(new RuleData(selector, rule.declarations, specificity, rules.length));
            }
        }

        return rules;
    }

    static function parseQuerySelectors(content:String):SelectorList {
        var input = new StringView(content);
        var selectors:SelectorList = [];
        stripLeadingAndTrailingSpaces(input);
        if (!parseSelectors(input, selectors)
            || !input.empty()) {
            return [];
        }

        return selectors;
    }

    static function parseInlineStyle(content:String, element:SVGElement):Void {
        var input = new StringView(content);
        skipOptionalSpaces(input);
        var name = readCSSIdentifier(input);
        while (name != null) {
            skipOptionalSpaces(input);
            if (!skipDelimiter(input, ':'.code))
                return;
            var start = input.pos;
            while (!input.empty() && input.front() != ';'.code) {
                input.removePrefix(1);
            }
            var value = input.data.substring(start, input.pos);

            var id = PropertyIds.csspropertyid(name);
            if (id != PropertyID.Unknown)
                element.setAttribute(0x100, id, value);
            skipOptionalSpacesOrDelimiter(input, ';'.code);
            name = readCSSIdentifier(input);
        }
    }

    static function removeStyleComments(value:String):String {
        var start = value.indexOf("/*");
        while (start >= 0) {
            var end = value.indexOf("*/", start + 2);
            if (end < 0)
                value = value.substr(0, start);
            else
                value = value.substr(0, start) + value.substr(end + 2);
            start = value.indexOf("/*");
        }
        return value;
    }

    /**
     * `decodeText()`: decodes XML entities. Returns null on error (the C++
     * code keeps the partial output and returns false, which is ignored).
     */
    static function decodeText(input:StringView):String {
        var output = new StringBuf();
        while (!input.empty()) {
            var ch = input.front();
            input.removePrefix(1);
            if (ch != '&'.code) {
                output.addChar(ch);
                continue;
            }

            if (skipDelimiter(input, '#'.code)) {
                var base = 10;
                if (skipDelimiter(input, 'x'.code))
                    base = 16;
                var cp = parseInteger(input, base);
                if (cp < 0)
                    return output.toString();
                if (cp < 0x200000 && cp != 0)
                    output.addChar(cp);
            } else {
                if (skipString(input, "amp")) {
                    output.addChar('&'.code);
                } else if (skipString(input, "lt")) {
                    output.addChar('<'.code);
                } else if (skipString(input, "gt")) {
                    output.addChar('>'.code);
                } else if (skipString(input, "quot")) {
                    output.addChar('"'.code);
                } else if (skipString(input, "apos")) {
                    output.addChar('\''.code);
                } else {
                    return output.toString();
                }
            }

            if (!skipDelimiter(input, ';'.code)) {
                return output.toString();
            }
        }

        return output.toString();
    }

    static inline function IS_STARTNAMECHAR(c:Int):Bool {
        return IS_ALPHA(c) || c == '_'.code || c == ':'.code;
    }

    static inline function IS_NAMECHAR(c:Int):Bool {
        return IS_STARTNAMECHAR(c) || IS_NUM(c) || c == '-'.code || c == '.'.code;
    }

    static function readIdentifier(input:StringView):Null<String> {
        if (input.empty() || !IS_STARTNAMECHAR(input.front()))
            return null;
        var start = input.pos;
        do {
            input.removePrefix(1);
        } while (!input.empty() && IS_NAMECHAR(input.front()));
        return input.data.substring(start, input.pos);
    }

    /**
     * `Document::parse()`.
     */
    public static function parse(document:Document, data:String):Bool {
        var styleSheet = new StringBuf();
        var currentElement:Null<SVGElement> = null;
        var ignoring = 0;
        function handleText(text:StringView, in_cdata:Bool):Void {
            if (text.empty() || currentElement == null || ignoring > 0)
                return;
            if (currentElement.id() != ElementID.Text && currentElement.id() != ElementID.Tspan && currentElement.id() != ElementID.Style) {
                return;
            }

            var buffer = in_cdata ? text.toString() : decodeText(text.clone());
            if (currentElement.id() == ElementID.Style) {
                buffer = removeStyleComments(buffer);
                styleSheet.add(buffer);
            } else {
                var node = new SVGTextNode(document);
                node.setData(buffer);
                currentElement.addChild(node);
            }
        }

        var input = new StringView(data);
        if (input.length() >= 1 && input.front() == 0xFEFF) {
            input.removePrefix(1);
        } else if (input.length() >= 3 && input.at(0) == 0xEF && input.at(1) == 0xBB && input.at(2) == 0xBF) {
            input.removePrefix(3);
        }

        while (!input.empty()) {
            if (currentElement != null) {
                var n = input.findChar('<'.code);
                var text = input.substr(0, n);
                handleText(text, false);
                input.removePrefix(text.length());
            } else {
                if (!skipOptionalSpaces(input)) {
                    break;
                }
            }

            if (!skipDelimiter(input, '<'.code))
                return false;
            if (skipDelimiter(input, '?'.code)) {
                if (readIdentifier(input) == null)
                    return false;
                var n = input.find("?>");
                if (n < 0)
                    return false;
                input.removePrefix(n + 2);
                continue;
            }

            if (skipDelimiter(input, '!'.code)) {
                if (skipString(input, "--")) {
                    var n = input.find("-->");
                    if (n < 0)
                        return false;
                    handleText(input.substr(0, n), false);
                    input.removePrefix(n + 3);
                    continue;
                }

                if (skipString(input, "[CDATA[")) {
                    var n = input.find("]]>");
                    if (n < 0)
                        return false;
                    handleText(input.substr(0, n), true);
                    input.removePrefix(n + 3);
                    continue;
                }

                if (skipString(input, "DOCTYPE")) {
                    while (!input.empty() && input.front() != '>'.code) {
                        if (input.front() == '['.code) {
                            var depth = 1;
                            input.removePrefix(1);
                            while (!input.empty() && depth > 0) {
                                if (input.front() == '['.code)
                                    ++depth;
                                else if (input.front() == ']'.code)
                                    --depth;
                                input.removePrefix(1);
                            }
                        } else {
                            input.removePrefix(1);
                        }
                    }

                    if (!skipDelimiter(input, '>'.code))
                        return false;
                    continue;
                }

                return false;
            }

            if (skipDelimiter(input, '/'.code)) {
                if (currentElement == null && ignoring == 0)
                    return false;
                var name = readIdentifier(input);
                if (name == null)
                    return false;
                if (ignoring == 0) {
                    var id = SVGElement.elementid(name);
                    if (id != currentElement.id())
                        return false;
                    currentElement = currentElement.parentElement();
                } else {
                    --ignoring;
                }

                skipOptionalSpaces(input);
                if (!skipDelimiter(input, '>'.code))
                    return false;
                continue;
            }

            var tagName = readIdentifier(input);
            if (tagName == null)
                return false;
            var element:Null<SVGElement> = null;
            if (ignoring > 0) {
                ++ignoring;
            } else {
                var id = SVGElement.elementid(tagName);
                if (id == ElementID.Unknown) {
                    ignoring = 1;
                } else {
                    if (document.m_rootElement != null && currentElement == null)
                        return false;
                    if (document.m_rootElement == null) {
                        if (id != ElementID.Svg)
                            return false;
                        document.m_rootElement = new SVGRootElement(document);
                        element = document.m_rootElement;
                    } else {
                        var child = SVGElement.create(document, id);
                        element = child;
                        currentElement.addChild(child);
                    }
                }
            }

            skipOptionalSpaces(input);
            var attrName = readIdentifier(input);
            while (attrName != null) {
                skipOptionalSpaces(input);
                if (!skipDelimiter(input, '='.code))
                    return false;
                skipOptionalSpaces(input);
                if (input.empty() || !(input.front() == '"'.code || input.front() == '\''.code))
                    return false;
                var quote = input.front();
                input.removePrefix(1);
                var n = input.findChar(quote);
                if (n < 0)
                    return false;
                var id = PropertyID.Unknown;
                if (element != null)
                    id = PropertyIds.propertyid(attrName);
                if (id != PropertyID.Unknown) {
                    var buffer = decodeText(input.substr(0, n));
                    if (id == PropertyID.Style) {
                        buffer = removeStyleComments(buffer);
                        parseInlineStyle(buffer, element);
                    } else {
                        if (id == PropertyID.Id)
                            document.m_rootElement.addElementById(buffer, element);
                        element.setAttribute(0x1, id, buffer);
                    }
                }

                input.removePrefix(n + 1);
                skipOptionalSpaces(input);
                attrName = readIdentifier(input);
            }

            if (skipDelimiter(input, '>'.code)) {
                if (element != null)
                    currentElement = element;
                continue;
            }

            if (skipDelimiter(input, '/'.code)) {
                if (!skipDelimiter(input, '>'.code))
                    return false;
                if (ignoring > 0)
                    --ignoring;
                continue;
            }

            return false;
        }

        if (document.m_rootElement == null || ignoring > 0 || !input.empty())
            return false;
        applyStyleSheet(document, styleSheet.toString());
        document.m_rootElement.build();
        return true;
    }

    /**
     * `Document::applyStyleSheet()`.
     */
    public static function applyStyleSheet(document:Document, content:String):Void {
        var rules = parseStyleSheet(content);
        if (rules.length > 0) {
            stableSort(rules);
            document.m_rootElement.transverse(function(element:SVGElement) {
                for (rule in rules) {
                    if (rule.match(element)) {
                        for (declaration in rule.declarations()) {
                            element.setAttribute(declaration.specificity, declaration.id, declaration.value);
                        }
                    }
                }
            });
        }
    }

    static function stableSort(rules:RuleDataList):Void {
        // (specificity, position) pairs are unique: any correct sort gives
        // the same order as std::sort.
        haxe.ds.ArraySort.sort(rules, function(a:RuleData, b:RuleData):Int {
            if (a.isLessThan(b))
                return -1;
            if (b.isLessThan(a))
                return 1;
            return 0;
        });
    }

    /**
     * `Document::querySelectorAll()`.
     */
    public static function querySelectorAll(document:Document, content:String):Array<SVGElement> {
        var selectors = parseQuerySelectors(content);
        if (selectors.length == 0)
            return [];
        var elements:Array<SVGElement> = [];
        document.m_rootElement.transverse(function(element:SVGElement) {
            for (selector in selectors) {
                if (matchSelector(selector, element)) {
                    elements.push(element);
                    break;
                }
            }
        });

        return elements;
    }

}

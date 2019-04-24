import 'dart:async';
import 'package:meta/meta.dart' show required;
import '../src/connection.dart';
import 'dom.dart' as dom;
import 'dom_debugger.dart' as dom_debugger;
import 'page.dart' as page;

/// This domain facilitates obtaining document snapshots with DOM, layout, and style information.
class DOMSnapshotApi {
  final Client _client;

  DOMSnapshotApi(this._client);

  /// Disables DOM snapshot agent for the given page.
  Future<void> disable() async {
    await _client.send('DOMSnapshot.disable');
  }

  /// Enables DOM snapshot agent for the given page.
  Future<void> enable() async {
    await _client.send('DOMSnapshot.enable');
  }

  /// Returns a document snapshot, including the full DOM tree of the root node (including iframes,
  /// template contents, and imported documents) in a flattened array, as well as layout and
  /// white-listed computed style information for the nodes. Shadow DOM in the returned DOM tree is
  /// flattened.
  /// [computedStyleWhitelist] Whitelist of computed styles to return.
  /// [includeEventListeners] Whether or not to retrieve details of DOM listeners (default false).
  /// [includePaintOrder] Whether to determine and include the paint order index of LayoutTreeNodes (default false).
  /// [includeUserAgentShadowTree] Whether to include UA shadow tree in the snapshot (default false).
  @deprecated
  Future<GetSnapshotResult> getSnapshot(List<String> computedStyleWhitelist,
      {bool includeEventListeners,
      bool includePaintOrder,
      bool includeUserAgentShadowTree}) async {
    var parameters = <String, dynamic>{
      'computedStyleWhitelist': computedStyleWhitelist.map((e) => e).toList(),
    };
    if (includeEventListeners != null) {
      parameters['includeEventListeners'] = includeEventListeners;
    }
    if (includePaintOrder != null) {
      parameters['includePaintOrder'] = includePaintOrder;
    }
    if (includeUserAgentShadowTree != null) {
      parameters['includeUserAgentShadowTree'] = includeUserAgentShadowTree;
    }
    var result = await _client.send('DOMSnapshot.getSnapshot', parameters);
    return GetSnapshotResult.fromJson(result);
  }

  /// Returns a document snapshot, including the full DOM tree of the root node (including iframes,
  /// template contents, and imported documents) in a flattened array, as well as layout and
  /// white-listed computed style information for the nodes. Shadow DOM in the returned DOM tree is
  /// flattened.
  /// [computedStyles] Whitelist of computed styles to return.
  Future<CaptureSnapshotResult> captureSnapshot(
      List<String> computedStyles) async {
    var parameters = <String, dynamic>{
      'computedStyles': computedStyles.map((e) => e).toList(),
    };
    var result = await _client.send('DOMSnapshot.captureSnapshot', parameters);
    return CaptureSnapshotResult.fromJson(result);
  }
}

class GetSnapshotResult {
  /// The nodes in the DOM tree. The DOMNode at index 0 corresponds to the root document.
  final List<DOMNode> domNodes;

  /// The nodes in the layout tree.
  final List<LayoutTreeNode> layoutTreeNodes;

  /// Whitelisted ComputedStyle properties for each node in the layout tree.
  final List<ComputedStyle> computedStyles;

  GetSnapshotResult(
      {@required this.domNodes,
      @required this.layoutTreeNodes,
      @required this.computedStyles});

  factory GetSnapshotResult.fromJson(Map<String, dynamic> json) {
    return GetSnapshotResult(
      domNodes:
          (json['domNodes'] as List).map((e) => DOMNode.fromJson(e)).toList(),
      layoutTreeNodes: (json['layoutTreeNodes'] as List)
          .map((e) => LayoutTreeNode.fromJson(e))
          .toList(),
      computedStyles: (json['computedStyles'] as List)
          .map((e) => ComputedStyle.fromJson(e))
          .toList(),
    );
  }
}

class CaptureSnapshotResult {
  /// The nodes in the DOM tree. The DOMNode at index 0 corresponds to the root document.
  final List<DocumentSnapshot> documents;

  /// Shared string table that all string properties refer to with indexes.
  final List<String> strings;

  CaptureSnapshotResult({@required this.documents, @required this.strings});

  factory CaptureSnapshotResult.fromJson(Map<String, dynamic> json) {
    return CaptureSnapshotResult(
      documents: (json['documents'] as List)
          .map((e) => DocumentSnapshot.fromJson(e))
          .toList(),
      strings: (json['strings'] as List).map((e) => e as String).toList(),
    );
  }
}

/// A Node in the DOM tree.
class DOMNode {
  /// `Node`'s nodeType.
  final int nodeType;

  /// `Node`'s nodeName.
  final String nodeName;

  /// `Node`'s nodeValue.
  final String nodeValue;

  /// Only set for textarea elements, contains the text value.
  final String textValue;

  /// Only set for input elements, contains the input's associated text value.
  final String inputValue;

  /// Only set for radio and checkbox input elements, indicates if the element has been checked
  final bool inputChecked;

  /// Only set for option elements, indicates if the element has been selected
  final bool optionSelected;

  /// `Node`'s id, corresponds to DOM.Node.backendNodeId.
  final dom.BackendNodeId backendNodeId;

  /// The indexes of the node's child nodes in the `domNodes` array returned by `getSnapshot`, if
  /// any.
  final List<int> childNodeIndexes;

  /// Attributes of an `Element` node.
  final List<NameValue> attributes;

  /// Indexes of pseudo elements associated with this node in the `domNodes` array returned by
  /// `getSnapshot`, if any.
  final List<int> pseudoElementIndexes;

  /// The index of the node's related layout tree node in the `layoutTreeNodes` array returned by
  /// `getSnapshot`, if any.
  final int layoutNodeIndex;

  /// Document URL that `Document` or `FrameOwner` node points to.
  final String documentURL;

  /// Base URL that `Document` or `FrameOwner` node uses for URL completion.
  final String baseURL;

  /// Only set for documents, contains the document's content language.
  final String contentLanguage;

  /// Only set for documents, contains the document's character set encoding.
  final String documentEncoding;

  /// `DocumentType` node's publicId.
  final String publicId;

  /// `DocumentType` node's systemId.
  final String systemId;

  /// Frame ID for frame owner elements and also for the document node.
  final page.FrameId frameId;

  /// The index of a frame owner element's content document in the `domNodes` array returned by
  /// `getSnapshot`, if any.
  final int contentDocumentIndex;

  /// Type of a pseudo element node.
  final dom.PseudoType pseudoType;

  /// Shadow root type.
  final dom.ShadowRootType shadowRootType;

  /// Whether this DOM node responds to mouse clicks. This includes nodes that have had click
  /// event listeners attached via JavaScript as well as anchor tags that naturally navigate when
  /// clicked.
  final bool isClickable;

  /// Details of the node's event listeners, if any.
  final List<dom_debugger.EventListener> eventListeners;

  /// The selected url for nodes with a srcset attribute.
  final String currentSourceURL;

  /// The url of the script (if any) that generates this node.
  final String originURL;

  /// Scroll offsets, set when this node is a Document.
  final num scrollOffsetX;

  final num scrollOffsetY;

  DOMNode(
      {@required this.nodeType,
      @required this.nodeName,
      @required this.nodeValue,
      this.textValue,
      this.inputValue,
      this.inputChecked,
      this.optionSelected,
      @required this.backendNodeId,
      this.childNodeIndexes,
      this.attributes,
      this.pseudoElementIndexes,
      this.layoutNodeIndex,
      this.documentURL,
      this.baseURL,
      this.contentLanguage,
      this.documentEncoding,
      this.publicId,
      this.systemId,
      this.frameId,
      this.contentDocumentIndex,
      this.pseudoType,
      this.shadowRootType,
      this.isClickable,
      this.eventListeners,
      this.currentSourceURL,
      this.originURL,
      this.scrollOffsetX,
      this.scrollOffsetY});

  factory DOMNode.fromJson(Map<String, dynamic> json) {
    return DOMNode(
      nodeType: json['nodeType'],
      nodeName: json['nodeName'],
      nodeValue: json['nodeValue'],
      textValue: json.containsKey('textValue') ? json['textValue'] : null,
      inputValue: json.containsKey('inputValue') ? json['inputValue'] : null,
      inputChecked:
          json.containsKey('inputChecked') ? json['inputChecked'] : null,
      optionSelected:
          json.containsKey('optionSelected') ? json['optionSelected'] : null,
      backendNodeId: dom.BackendNodeId.fromJson(json['backendNodeId']),
      childNodeIndexes: json.containsKey('childNodeIndexes')
          ? (json['childNodeIndexes'] as List).map((e) => e as int).toList()
          : null,
      attributes: json.containsKey('attributes')
          ? (json['attributes'] as List)
              .map((e) => NameValue.fromJson(e))
              .toList()
          : null,
      pseudoElementIndexes: json.containsKey('pseudoElementIndexes')
          ? (json['pseudoElementIndexes'] as List).map((e) => e as int).toList()
          : null,
      layoutNodeIndex:
          json.containsKey('layoutNodeIndex') ? json['layoutNodeIndex'] : null,
      documentURL: json.containsKey('documentURL') ? json['documentURL'] : null,
      baseURL: json.containsKey('baseURL') ? json['baseURL'] : null,
      contentLanguage:
          json.containsKey('contentLanguage') ? json['contentLanguage'] : null,
      documentEncoding: json.containsKey('documentEncoding')
          ? json['documentEncoding']
          : null,
      publicId: json.containsKey('publicId') ? json['publicId'] : null,
      systemId: json.containsKey('systemId') ? json['systemId'] : null,
      frameId: json.containsKey('frameId')
          ? page.FrameId.fromJson(json['frameId'])
          : null,
      contentDocumentIndex: json.containsKey('contentDocumentIndex')
          ? json['contentDocumentIndex']
          : null,
      pseudoType: json.containsKey('pseudoType')
          ? dom.PseudoType.fromJson(json['pseudoType'])
          : null,
      shadowRootType: json.containsKey('shadowRootType')
          ? dom.ShadowRootType.fromJson(json['shadowRootType'])
          : null,
      isClickable: json.containsKey('isClickable') ? json['isClickable'] : null,
      eventListeners: json.containsKey('eventListeners')
          ? (json['eventListeners'] as List)
              .map((e) => dom_debugger.EventListener.fromJson(e))
              .toList()
          : null,
      currentSourceURL: json.containsKey('currentSourceURL')
          ? json['currentSourceURL']
          : null,
      originURL: json.containsKey('originURL') ? json['originURL'] : null,
      scrollOffsetX:
          json.containsKey('scrollOffsetX') ? json['scrollOffsetX'] : null,
      scrollOffsetY:
          json.containsKey('scrollOffsetY') ? json['scrollOffsetY'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'nodeType': nodeType,
      'nodeName': nodeName,
      'nodeValue': nodeValue,
      'backendNodeId': backendNodeId.toJson(),
    };
    if (textValue != null) {
      json['textValue'] = textValue;
    }
    if (inputValue != null) {
      json['inputValue'] = inputValue;
    }
    if (inputChecked != null) {
      json['inputChecked'] = inputChecked;
    }
    if (optionSelected != null) {
      json['optionSelected'] = optionSelected;
    }
    if (childNodeIndexes != null) {
      json['childNodeIndexes'] = childNodeIndexes.map((e) => e).toList();
    }
    if (attributes != null) {
      json['attributes'] = attributes.map((e) => e.toJson()).toList();
    }
    if (pseudoElementIndexes != null) {
      json['pseudoElementIndexes'] =
          pseudoElementIndexes.map((e) => e).toList();
    }
    if (layoutNodeIndex != null) {
      json['layoutNodeIndex'] = layoutNodeIndex;
    }
    if (documentURL != null) {
      json['documentURL'] = documentURL;
    }
    if (baseURL != null) {
      json['baseURL'] = baseURL;
    }
    if (contentLanguage != null) {
      json['contentLanguage'] = contentLanguage;
    }
    if (documentEncoding != null) {
      json['documentEncoding'] = documentEncoding;
    }
    if (publicId != null) {
      json['publicId'] = publicId;
    }
    if (systemId != null) {
      json['systemId'] = systemId;
    }
    if (frameId != null) {
      json['frameId'] = frameId.toJson();
    }
    if (contentDocumentIndex != null) {
      json['contentDocumentIndex'] = contentDocumentIndex;
    }
    if (pseudoType != null) {
      json['pseudoType'] = pseudoType.toJson();
    }
    if (shadowRootType != null) {
      json['shadowRootType'] = shadowRootType.toJson();
    }
    if (isClickable != null) {
      json['isClickable'] = isClickable;
    }
    if (eventListeners != null) {
      json['eventListeners'] = eventListeners.map((e) => e.toJson()).toList();
    }
    if (currentSourceURL != null) {
      json['currentSourceURL'] = currentSourceURL;
    }
    if (originURL != null) {
      json['originURL'] = originURL;
    }
    if (scrollOffsetX != null) {
      json['scrollOffsetX'] = scrollOffsetX;
    }
    if (scrollOffsetY != null) {
      json['scrollOffsetY'] = scrollOffsetY;
    }
    return json;
  }
}

/// Details of post layout rendered text positions. The exact layout should not be regarded as
/// stable and may change between versions.
class InlineTextBox {
  /// The bounding box in document coordinates. Note that scroll offset of the document is ignored.
  final dom.Rect boundingBox;

  /// The starting index in characters, for this post layout textbox substring. Characters that
  /// would be represented as a surrogate pair in UTF-16 have length 2.
  final int startCharacterIndex;

  /// The number of characters in this post layout textbox substring. Characters that would be
  /// represented as a surrogate pair in UTF-16 have length 2.
  final int numCharacters;

  InlineTextBox(
      {@required this.boundingBox,
      @required this.startCharacterIndex,
      @required this.numCharacters});

  factory InlineTextBox.fromJson(Map<String, dynamic> json) {
    return InlineTextBox(
      boundingBox: dom.Rect.fromJson(json['boundingBox']),
      startCharacterIndex: json['startCharacterIndex'],
      numCharacters: json['numCharacters'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'boundingBox': boundingBox.toJson(),
      'startCharacterIndex': startCharacterIndex,
      'numCharacters': numCharacters,
    };
    return json;
  }
}

/// Details of an element in the DOM tree with a LayoutObject.
class LayoutTreeNode {
  /// The index of the related DOM node in the `domNodes` array returned by `getSnapshot`.
  final int domNodeIndex;

  /// The bounding box in document coordinates. Note that scroll offset of the document is ignored.
  final dom.Rect boundingBox;

  /// Contents of the LayoutText, if any.
  final String layoutText;

  /// The post-layout inline text nodes, if any.
  final List<InlineTextBox> inlineTextNodes;

  /// Index into the `computedStyles` array returned by `getSnapshot`.
  final int styleIndex;

  /// Global paint order index, which is determined by the stacking order of the nodes. Nodes
  /// that are painted together will have the same index. Only provided if includePaintOrder in
  /// getSnapshot was true.
  final int paintOrder;

  /// Set to true to indicate the element begins a new stacking context.
  final bool isStackingContext;

  LayoutTreeNode(
      {@required this.domNodeIndex,
      @required this.boundingBox,
      this.layoutText,
      this.inlineTextNodes,
      this.styleIndex,
      this.paintOrder,
      this.isStackingContext});

  factory LayoutTreeNode.fromJson(Map<String, dynamic> json) {
    return LayoutTreeNode(
      domNodeIndex: json['domNodeIndex'],
      boundingBox: dom.Rect.fromJson(json['boundingBox']),
      layoutText: json.containsKey('layoutText') ? json['layoutText'] : null,
      inlineTextNodes: json.containsKey('inlineTextNodes')
          ? (json['inlineTextNodes'] as List)
              .map((e) => InlineTextBox.fromJson(e))
              .toList()
          : null,
      styleIndex: json.containsKey('styleIndex') ? json['styleIndex'] : null,
      paintOrder: json.containsKey('paintOrder') ? json['paintOrder'] : null,
      isStackingContext: json.containsKey('isStackingContext')
          ? json['isStackingContext']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'domNodeIndex': domNodeIndex,
      'boundingBox': boundingBox.toJson(),
    };
    if (layoutText != null) {
      json['layoutText'] = layoutText;
    }
    if (inlineTextNodes != null) {
      json['inlineTextNodes'] = inlineTextNodes.map((e) => e.toJson()).toList();
    }
    if (styleIndex != null) {
      json['styleIndex'] = styleIndex;
    }
    if (paintOrder != null) {
      json['paintOrder'] = paintOrder;
    }
    if (isStackingContext != null) {
      json['isStackingContext'] = isStackingContext;
    }
    return json;
  }
}

/// A subset of the full ComputedStyle as defined by the request whitelist.
class ComputedStyle {
  /// Name/value pairs of computed style properties.
  final List<NameValue> properties;

  ComputedStyle({@required this.properties});

  factory ComputedStyle.fromJson(Map<String, dynamic> json) {
    return ComputedStyle(
      properties: (json['properties'] as List)
          .map((e) => NameValue.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'properties': properties.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

/// A name/value pair.
class NameValue {
  /// Attribute/property name.
  final String name;

  /// Attribute/property value.
  final String value;

  NameValue({@required this.name, @required this.value});

  factory NameValue.fromJson(Map<String, dynamic> json) {
    return NameValue(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'name': name,
      'value': value,
    };
    return json;
  }
}

/// Index of the string in the strings table.
class StringIndex {
  final int value;

  StringIndex(this.value);

  factory StringIndex.fromJson(int value) => StringIndex(value);

  int toJson() => value;

  @override
  bool operator ==(other) =>
      (other is StringIndex && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Index of the string in the strings table.
class ArrayOfStrings {
  final List<StringIndex> value;

  ArrayOfStrings(this.value);

  factory ArrayOfStrings.fromJson(List<dynamic> value) =>
      ArrayOfStrings(List<StringIndex>.from(value));

  List<StringIndex> toJson() => value;

  @override
  bool operator ==(other) =>
      (other is ArrayOfStrings && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Data that is only present on rare nodes.
class RareStringData {
  final List<int> index;

  final List<StringIndex> value;

  RareStringData({@required this.index, @required this.value});

  factory RareStringData.fromJson(Map<String, dynamic> json) {
    return RareStringData(
      index: (json['index'] as List).map((e) => e as int).toList(),
      value:
          (json['value'] as List).map((e) => StringIndex.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'index': index.map((e) => e).toList(),
      'value': value.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}

class RareBooleanData {
  final List<int> index;

  RareBooleanData({@required this.index});

  factory RareBooleanData.fromJson(Map<String, dynamic> json) {
    return RareBooleanData(
      index: (json['index'] as List).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'index': index.map((e) => e).toList(),
    };
    return json;
  }
}

class RareIntegerData {
  final List<int> index;

  final List<int> value;

  RareIntegerData({@required this.index, @required this.value});

  factory RareIntegerData.fromJson(Map<String, dynamic> json) {
    return RareIntegerData(
      index: (json['index'] as List).map((e) => e as int).toList(),
      value: (json['value'] as List).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'index': index.map((e) => e).toList(),
      'value': value.map((e) => e).toList(),
    };
    return json;
  }
}

class Rectangle {
  final List<num> value;

  Rectangle(this.value);

  factory Rectangle.fromJson(List<dynamic> value) =>
      Rectangle(List<num>.from(value));

  List<num> toJson() => value;

  @override
  bool operator ==(other) =>
      (other is Rectangle && other.value == value) || value == other;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Document snapshot.
class DocumentSnapshot {
  /// Document URL that `Document` or `FrameOwner` node points to.
  final StringIndex documentURL;

  /// Base URL that `Document` or `FrameOwner` node uses for URL completion.
  final StringIndex baseURL;

  /// Contains the document's content language.
  final StringIndex contentLanguage;

  /// Contains the document's character set encoding.
  final StringIndex encodingName;

  /// `DocumentType` node's publicId.
  final StringIndex publicId;

  /// `DocumentType` node's systemId.
  final StringIndex systemId;

  /// Frame ID for frame owner elements and also for the document node.
  final StringIndex frameId;

  /// A table with dom nodes.
  final NodeTreeSnapshot nodes;

  /// The nodes in the layout tree.
  final LayoutTreeSnapshot layout;

  /// The post-layout inline text nodes.
  final TextBoxSnapshot textBoxes;

  /// Scroll offsets.
  final num scrollOffsetX;

  final num scrollOffsetY;

  DocumentSnapshot(
      {@required this.documentURL,
      @required this.baseURL,
      @required this.contentLanguage,
      @required this.encodingName,
      @required this.publicId,
      @required this.systemId,
      @required this.frameId,
      @required this.nodes,
      @required this.layout,
      @required this.textBoxes,
      this.scrollOffsetX,
      this.scrollOffsetY});

  factory DocumentSnapshot.fromJson(Map<String, dynamic> json) {
    return DocumentSnapshot(
      documentURL: StringIndex.fromJson(json['documentURL']),
      baseURL: StringIndex.fromJson(json['baseURL']),
      contentLanguage: StringIndex.fromJson(json['contentLanguage']),
      encodingName: StringIndex.fromJson(json['encodingName']),
      publicId: StringIndex.fromJson(json['publicId']),
      systemId: StringIndex.fromJson(json['systemId']),
      frameId: StringIndex.fromJson(json['frameId']),
      nodes: NodeTreeSnapshot.fromJson(json['nodes']),
      layout: LayoutTreeSnapshot.fromJson(json['layout']),
      textBoxes: TextBoxSnapshot.fromJson(json['textBoxes']),
      scrollOffsetX:
          json.containsKey('scrollOffsetX') ? json['scrollOffsetX'] : null,
      scrollOffsetY:
          json.containsKey('scrollOffsetY') ? json['scrollOffsetY'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'documentURL': documentURL.toJson(),
      'baseURL': baseURL.toJson(),
      'contentLanguage': contentLanguage.toJson(),
      'encodingName': encodingName.toJson(),
      'publicId': publicId.toJson(),
      'systemId': systemId.toJson(),
      'frameId': frameId.toJson(),
      'nodes': nodes.toJson(),
      'layout': layout.toJson(),
      'textBoxes': textBoxes.toJson(),
    };
    if (scrollOffsetX != null) {
      json['scrollOffsetX'] = scrollOffsetX;
    }
    if (scrollOffsetY != null) {
      json['scrollOffsetY'] = scrollOffsetY;
    }
    return json;
  }
}

/// Table containing nodes.
class NodeTreeSnapshot {
  /// Parent node index.
  final List<int> parentIndex;

  /// `Node`'s nodeType.
  final List<int> nodeType;

  /// `Node`'s nodeName.
  final List<StringIndex> nodeName;

  /// `Node`'s nodeValue.
  final List<StringIndex> nodeValue;

  /// `Node`'s id, corresponds to DOM.Node.backendNodeId.
  final List<dom.BackendNodeId> backendNodeId;

  /// Attributes of an `Element` node. Flatten name, value pairs.
  final List<ArrayOfStrings> attributes;

  /// Only set for textarea elements, contains the text value.
  final RareStringData textValue;

  /// Only set for input elements, contains the input's associated text value.
  final RareStringData inputValue;

  /// Only set for radio and checkbox input elements, indicates if the element has been checked
  final RareBooleanData inputChecked;

  /// Only set for option elements, indicates if the element has been selected
  final RareBooleanData optionSelected;

  /// The index of the document in the list of the snapshot documents.
  final RareIntegerData contentDocumentIndex;

  /// Type of a pseudo element node.
  final RareStringData pseudoType;

  /// Whether this DOM node responds to mouse clicks. This includes nodes that have had click
  /// event listeners attached via JavaScript as well as anchor tags that naturally navigate when
  /// clicked.
  final RareBooleanData isClickable;

  /// The selected url for nodes with a srcset attribute.
  final RareStringData currentSourceURL;

  /// The url of the script (if any) that generates this node.
  final RareStringData originURL;

  NodeTreeSnapshot(
      {this.parentIndex,
      this.nodeType,
      this.nodeName,
      this.nodeValue,
      this.backendNodeId,
      this.attributes,
      this.textValue,
      this.inputValue,
      this.inputChecked,
      this.optionSelected,
      this.contentDocumentIndex,
      this.pseudoType,
      this.isClickable,
      this.currentSourceURL,
      this.originURL});

  factory NodeTreeSnapshot.fromJson(Map<String, dynamic> json) {
    return NodeTreeSnapshot(
      parentIndex: json.containsKey('parentIndex')
          ? (json['parentIndex'] as List).map((e) => e as int).toList()
          : null,
      nodeType: json.containsKey('nodeType')
          ? (json['nodeType'] as List).map((e) => e as int).toList()
          : null,
      nodeName: json.containsKey('nodeName')
          ? (json['nodeName'] as List)
              .map((e) => StringIndex.fromJson(e))
              .toList()
          : null,
      nodeValue: json.containsKey('nodeValue')
          ? (json['nodeValue'] as List)
              .map((e) => StringIndex.fromJson(e))
              .toList()
          : null,
      backendNodeId: json.containsKey('backendNodeId')
          ? (json['backendNodeId'] as List)
              .map((e) => dom.BackendNodeId.fromJson(e))
              .toList()
          : null,
      attributes: json.containsKey('attributes')
          ? (json['attributes'] as List)
              .map((e) => ArrayOfStrings.fromJson(e))
              .toList()
          : null,
      textValue: json.containsKey('textValue')
          ? RareStringData.fromJson(json['textValue'])
          : null,
      inputValue: json.containsKey('inputValue')
          ? RareStringData.fromJson(json['inputValue'])
          : null,
      inputChecked: json.containsKey('inputChecked')
          ? RareBooleanData.fromJson(json['inputChecked'])
          : null,
      optionSelected: json.containsKey('optionSelected')
          ? RareBooleanData.fromJson(json['optionSelected'])
          : null,
      contentDocumentIndex: json.containsKey('contentDocumentIndex')
          ? RareIntegerData.fromJson(json['contentDocumentIndex'])
          : null,
      pseudoType: json.containsKey('pseudoType')
          ? RareStringData.fromJson(json['pseudoType'])
          : null,
      isClickable: json.containsKey('isClickable')
          ? RareBooleanData.fromJson(json['isClickable'])
          : null,
      currentSourceURL: json.containsKey('currentSourceURL')
          ? RareStringData.fromJson(json['currentSourceURL'])
          : null,
      originURL: json.containsKey('originURL')
          ? RareStringData.fromJson(json['originURL'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};
    if (parentIndex != null) {
      json['parentIndex'] = parentIndex.map((e) => e).toList();
    }
    if (nodeType != null) {
      json['nodeType'] = nodeType.map((e) => e).toList();
    }
    if (nodeName != null) {
      json['nodeName'] = nodeName.map((e) => e.toJson()).toList();
    }
    if (nodeValue != null) {
      json['nodeValue'] = nodeValue.map((e) => e.toJson()).toList();
    }
    if (backendNodeId != null) {
      json['backendNodeId'] = backendNodeId.map((e) => e.toJson()).toList();
    }
    if (attributes != null) {
      json['attributes'] = attributes.map((e) => e.toJson()).toList();
    }
    if (textValue != null) {
      json['textValue'] = textValue.toJson();
    }
    if (inputValue != null) {
      json['inputValue'] = inputValue.toJson();
    }
    if (inputChecked != null) {
      json['inputChecked'] = inputChecked.toJson();
    }
    if (optionSelected != null) {
      json['optionSelected'] = optionSelected.toJson();
    }
    if (contentDocumentIndex != null) {
      json['contentDocumentIndex'] = contentDocumentIndex.toJson();
    }
    if (pseudoType != null) {
      json['pseudoType'] = pseudoType.toJson();
    }
    if (isClickable != null) {
      json['isClickable'] = isClickable.toJson();
    }
    if (currentSourceURL != null) {
      json['currentSourceURL'] = currentSourceURL.toJson();
    }
    if (originURL != null) {
      json['originURL'] = originURL.toJson();
    }
    return json;
  }
}

/// Details of an element in the DOM tree with a LayoutObject.
class LayoutTreeSnapshot {
  /// The index of the related DOM node in the `domNodes` array returned by `getSnapshot`.
  final List<int> nodeIndex;

  /// Index into the `computedStyles` array returned by `captureSnapshot`.
  final List<ArrayOfStrings> styles;

  /// The absolute position bounding box.
  final List<Rectangle> bounds;

  /// Contents of the LayoutText, if any.
  final List<StringIndex> text;

  /// Stacking context information.
  final RareBooleanData stackingContexts;

  LayoutTreeSnapshot(
      {@required this.nodeIndex,
      @required this.styles,
      @required this.bounds,
      @required this.text,
      @required this.stackingContexts});

  factory LayoutTreeSnapshot.fromJson(Map<String, dynamic> json) {
    return LayoutTreeSnapshot(
      nodeIndex: (json['nodeIndex'] as List).map((e) => e as int).toList(),
      styles: (json['styles'] as List)
          .map((e) => ArrayOfStrings.fromJson(e))
          .toList(),
      bounds:
          (json['bounds'] as List).map((e) => Rectangle.fromJson(e)).toList(),
      text: (json['text'] as List).map((e) => StringIndex.fromJson(e)).toList(),
      stackingContexts: RareBooleanData.fromJson(json['stackingContexts']),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'nodeIndex': nodeIndex.map((e) => e).toList(),
      'styles': styles.map((e) => e.toJson()).toList(),
      'bounds': bounds.map((e) => e.toJson()).toList(),
      'text': text.map((e) => e.toJson()).toList(),
      'stackingContexts': stackingContexts.toJson(),
    };
    return json;
  }
}

/// Details of post layout rendered text positions. The exact layout should not be regarded as
/// stable and may change between versions.
class TextBoxSnapshot {
  /// Intex of th elayout tree node that owns this box collection.
  final List<int> layoutIndex;

  /// The absolute position bounding box.
  final List<Rectangle> bounds;

  /// The starting index in characters, for this post layout textbox substring. Characters that
  /// would be represented as a surrogate pair in UTF-16 have length 2.
  final List<int> start;

  /// The number of characters in this post layout textbox substring. Characters that would be
  /// represented as a surrogate pair in UTF-16 have length 2.
  final List<int> length;

  TextBoxSnapshot(
      {@required this.layoutIndex,
      @required this.bounds,
      @required this.start,
      @required this.length});

  factory TextBoxSnapshot.fromJson(Map<String, dynamic> json) {
    return TextBoxSnapshot(
      layoutIndex: (json['layoutIndex'] as List).map((e) => e as int).toList(),
      bounds:
          (json['bounds'] as List).map((e) => Rectangle.fromJson(e)).toList(),
      start: (json['start'] as List).map((e) => e as int).toList(),
      length: (json['length'] as List).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{
      'layoutIndex': layoutIndex.map((e) => e).toList(),
      'bounds': bounds.map((e) => e.toJson()).toList(),
      'start': start.map((e) => e).toList(),
      'length': length.map((e) => e).toList(),
    };
    return json;
  }
}

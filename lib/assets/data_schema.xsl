<!--test with 
xmllint -noout data_schema.xml -schema data_schema.xsd && saxonb-xslt -xsl:data_schema.xsl -s:data_schema.xml | html2text | sed 's/ *\* //g'
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <xsl:key name="properties" match="property" use="@name"/>
  <xsl:template match="/">
    <html>
      <body>
        <ul>
          <!--<li>-->
<!--delete from IdealAEnt;</li>-->
          <!--<li>-->
<!--delete from IdealReln;</li>-->
          <!--<li>-->
<!--delete from AEntType;</li>-->
          <!--<li>-->
<!--delete from RelnType;</li>-->
          <!--<li>-->
<!--delete from Attributekey;-->
          <!--</li>-->
          <xsl:for-each select="//property[count(. | key('properties', @name)[1]) = 1]">
            <li>
INSERT INTO AttributeKey(                           AttributeID
                                                  , AttributeType
                                                  , AttributeName
<xsl:if test="description != ''">                 , AttributeDescription</xsl:if>
<xsl:if test="@file = 'true'">                    , AttributeIsFile</xsl:if>
<xsl:if test="@sync = 'true'">                    , AttributeIsSync</xsl:if>
<xsl:if test="@thumbnail = 'true'">               , AttributeUseThumbnail</xsl:if>
<xsl:if test="formatString != ''">                , formatString</xsl:if>
<xsl:if test="@SemanticMapObjectURI != ''">             , SemanticMapObjectURI</xsl:if> 
<xsl:if test="@SemanticMapPredicate != ''">, SemanticMapPredicate</xsl:if> 
<xsl:if test="appendCharacterString != ''">       , appendCharacterString</xsl:if>)
  VALUES(                                           '<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>'
                                                  , '<xsl:value-of select="normalize-space(@type)"/>'
                                                  , '<xsl:value-of select="normalize-space(@name)"/>'
<xsl:if test="description != ''">                 , '<xsl:value-of select="normalize-space(description)"/>'</xsl:if>
<xsl:if test="@file = 'true'">                    , '1'</xsl:if>
<xsl:if test="@sync = 'true'">                    , '1'</xsl:if>
<xsl:if test="@thumbnail = 'true'">               , '1'</xsl:if>
<xsl:if test="formatString != ''">                , '<xsl:value-of select="formatString"/>'</xsl:if>
<xsl:if test="@SemanticMapObjectURI != ''">             , '<xsl:value-of select="normalize-space(@SemanticMapObjectURI)"/>'</xsl:if>
<xsl:if test="@SemanticMapPredicate != ''">, '<xsl:value-of select="normalize-space(@SemanticMapPredicate)"/>'</xsl:if>
<xsl:if test="appendCharacterString != ''">       , '<xsl:value-of select="appendCharacterString"/>'</xsl:if>);
            </li>
            <ul>
              <xsl:for-each select="lookup">
                <xsl:for-each select="descendant::term">
                  <li>
INSERT INTO Vocabulary (                            vocabId
                                                  , attributeid
                                                  , vocabname
<xsl:if test="@pictureURL != ''">                 , pictureURL</xsl:if>
<xsl:if test="description != ''">                 , vocabdescription</xsl:if>
<xsl:if test="@SemanticMapObjectURI != ''">             , SemanticMapObjectURI</xsl:if>
<xsl:if test="@SemanticMapPredicate != ''">, SemanticMapPredicate</xsl:if>
<xsl:if test="ancestor::term">                    , parentVocabID</xsl:if>
<xsl:if test="@VocabDateFrom">                    , VocabDateFrom</xsl:if>
<xsl:if test="@VocabDateTo">                      , VocabDateTo</xsl:if>
<xsl:if test="@VocabDateAnnotation">              , VocabDateAnnotation</xsl:if>
<xsl:if test="@VocabProvenance">                  , VocabProvenance</xsl:if>
<xsl:if test="@VocabDateCertainty">               , VocabDateCertainty</xsl:if>
<xsl:if test="@VocabType">                        , VocabType</xsl:if>
<xsl:if test="@VocabMaker">                       , VocabMaker</xsl:if>
                                                  , VocabCountOrder)
  VALUES(                                           '<xsl:value-of select="substring(generate-id(.),4)"/>'
                                                  , '<xsl:value-of select="substring(generate-id(key('properties',ancestor::property/@name)),4)"/>'
                                                  , '<xsl:value-of select="normalize-space(./text())"/>'
<xsl:if test="@pictureURL != ''">                 , '<xsl:value-of select="normalize-space(@pictureURL)"/>'</xsl:if>
<xsl:if test="description != ''">                 , '<xsl:value-of select="normalize-space(description)"/>'</xsl:if>
<xsl:if test="@SemanticMapObjectURI != ''">             , '<xsl:value-of select="normalize-space(@SemanticMapObjectURI)"/>'</xsl:if>
<xsl:if test="@SemanticMapPredicate != ''">, '<xsl:value-of select="normalize-space(@SemanticMapPredicate)"/>'</xsl:if>
<xsl:if test="ancestor::term">                    , <xsl:value-of select="substring(generate-id(..),4)"/></xsl:if>
<xsl:if test="@VocabDateFrom != ''">              , '<xsl:value-of select="normalize-space(@VocabDateFrom)"/>'</xsl:if>
<xsl:if test="@VocabDateTo != ''">                , '<xsl:value-of select="normalize-space(@VocabDateTo)"/>'</xsl:if>
<xsl:if test="@VocabDateAnnotation != ''">        , '<xsl:value-of select="normalize-space(@VocabDateAnnotation)"/>'</xsl:if>
<xsl:if test="@VocabProvenance != ''">            , '<xsl:value-of select="normalize-space(@VocabProvenance)"/>'</xsl:if>
<xsl:if test="@VocabDateCertainty != ''">         , '<xsl:value-of select="normalize-space(@VocabDateCertainty)"/>'</xsl:if>
<xsl:if test="@VocabType != ''">                  , '<xsl:value-of select="normalize-space(@VocabType)"/>'</xsl:if>
<xsl:if test="@VocabMaker != ''">                 , '<xsl:value-of select="normalize-space(@VocabMaker)"/>'</xsl:if>
                                                  , <xsl:number count="term" format="1"/>);
                  </li>
                </xsl:for-each>
              </xsl:for-each>
            </ul>
          </xsl:for-each>

          <xsl:for-each select="dataSchema/RelationshipElement">
            <li>
INSERT INTO RelnType(                                       RelnTypeID
                                                          , RelnTypeName
                                                          , RelnTypeDescription
                                                          , RelnTypeCategory
                                                          , Parent
                                                          , Child
<xsl:if test="@SemanticMapObjectURI != ''">                     , SemanticMapObjectURI</xsl:if>
<xsl:if test="@SemanticMapPredicate != ''">        , SemanticMapPredicate</xsl:if>
<xsl:if test="parent/@SemanticMapObjectURI != ''">              , semanticMapParentURL</xsl:if>
<xsl:if test="parent/@SemanticMapPredicate != ''"> , SemanticMapParentRelationshipSKOS</xsl:if>
<xsl:if test="child/@SemanticMapObjectURI != ''">               , semanticMapChildURL</xsl:if>
<xsl:if test="child/@SemanticMapPredicate != ''">  , SemanticMapChildRelationshipSKOS</xsl:if>)
VALUES(                                                     '<xsl:value-of select="substring(generate-id(.),4)"/>'
                                                          , '<xsl:value-of select="normalize-space(@name)"/>'
                                                          , '<xsl:value-of select="normalize-space(description)"/>'
                                                          , '<xsl:value-of select="normalize-space(@type)"/>'
                                                          , '<xsl:value-of select="normalize-space(parent)"/>'
                                                          , '<xsl:value-of select="normalize-space(child)"/>'
<xsl:if test="@SemanticMapObjectURI != ''">                     , '<xsl:value-of select="normalize-space(@SemanticMapObjectURI)"/>'</xsl:if>
<xsl:if test="@SemanticMapPredicate != ''">        , '<xsl:value-of select="normalize-space(@SemanticMapPredicate)"/>'</xsl:if>
<xsl:if test="parent/@SemanticMapObjectURI != ''">              , '<xsl:value-of select="normalize-space(parent/@SemanticMapObjectURI)"/>'</xsl:if>
<xsl:if test="parent/@SemanticMapPredicate != ''"> , '<xsl:value-of select="normalize-space(parent/@SemanticMapPredicate)"/>'</xsl:if>
<xsl:if test="child/@SemanticMapObjectURI != ''">               , '<xsl:value-of select="normalize-space(child/@SemanticMapObjectURI)"/>'</xsl:if>
<xsl:if test="child/@SemanticMapPredicate != ''">  , '<xsl:value-of select="normalize-space(child/@SemanticMapPredicate)"/>'</xsl:if>);
            </li>
            <ul>
              <xsl:for-each select="property">
                <li>
INSERT INTO IdealReln(RelnTypeID
                , AttributeID
                , MinCardinality
                , MaxCardinality
                , isIdentifier)
VALUES(           '<xsl:value-of select="substring(generate-id(..),4)"/>'
                , '<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>'
                , '<xsl:value-of select="normalize-space(@minCardinality)"/>'
                , '<xsl:value-of select="normalize-space(@maxCardinality)"/>'
                , '<xsl:value-of select="normalize-space(@isIdentifier)"/>');
                </li>
              </xsl:for-each>
            </ul>
          </xsl:for-each>

          <xsl:for-each select="dataSchema/ArchaeologicalElement">
            <li>
INSERT INTO AEntType (                              AEntTypeID
                                                  , AEntTypeName
                                                  , AEntTypeDescription
<xsl:if test="@SemanticMapObjectURI != ''">             , SemanticMapObjectURI</xsl:if>
<xsl:if test="@SemanticMapPredicate != ''">, SemanticMapPredicate</xsl:if>
)
VALUES (                                            '<xsl:value-of select="substring(generate-id(.),4)"/>'
                                                  , '<xsl:value-of select="normalize-space(@name | @type)"/>'
                                                  , '<xsl:value-of select="normalize-space(description)"/>'
<xsl:if test="@SemanticMapObjectURI != ''">             , '<xsl:value-of select="normalize-space(@SemanticMapObjectURI)"/>'</xsl:if>
<xsl:if test="@SemanticMapPredicate != ''">, '<xsl:value-of select="normalize-space(@SemanticMapPredicate)"/>'</xsl:if>);
            </li>
            <ul>
              <xsl:for-each select="property">
                <li>
INSERT INTO IdealAEnt(AEntTypeID
                    , AttributeID
                    , MinCardinality
                    , MaxCardinality
                    , isIdentifier
                    , AEntCountOrder)
VALUES(               '<xsl:value-of select="substring(generate-id(..),4)"/>'
                    , '<xsl:value-of select="substring(generate-id(key('properties',@name)),4)"/>'
                    , '<xsl:value-of select="normalize-space(@minCardinality)"/>'
                    , '<xsl:value-of select="normalize-space(@maxCardinality)"/>'
                    , '<xsl:value-of select="normalize-space(@isIdentifier)"/>'
                    , '<xsl:number count="property" format="1"/>');
                </li>
              </xsl:for-each>
            </ul>
          </xsl:for-each>
        </ul>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>


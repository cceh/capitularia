<schema xmlns="http://purl.oclc.org/dsdl/schematron">
  <ns uri="http://www.tei-c.org/ns/1.0" prefix="tei" />
  <pattern>
    <rule context="tei:*[@corresp and not (contains (@corresp, 'inscriptio_c'))]">
      <report test="following::tei:anchor[concat ('#', @xml:id) = current()/preceding::tei:milestone[@unit='capitulatio'][1]/@spanTo]">
        @corresp without "inscriptio_c" inside a capitulatio
      </report>
    </rule>
  </pattern>
</schema>

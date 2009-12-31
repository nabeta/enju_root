xml.instruct! :xml, :version=>"1.0" 
xml.CRD('version' => "1.0"){
  xml.REFERENCE{
    xml.QUESTION h(@question.body)
    xml.tag! 'ACC-LEVEL', '1'
    xml.tag! 'REG-ID', 'dummny'
    xml.ANSWER h(@question.answers.first)
    xml.tag! 'CRT-DATE'
    xml.SOLUTION
    # xml.KEYWORD @question.tags.collect(&:name).join(' ')
    xml.KEYWORD
    xml.CLASS :type => 'NDC'
    xml.tag! 'RES-TYPE', '1'
    xml.tag! 'CON-TYPE'
    @question.answers.each do
      xml.BIBL{
        xml.tag! 'BIBL-DESC'
        xml.tag! 'BIBL-NOTE'
      }
    end
    xml.tag! 'ANS-PROC'
    xml.REFERRAL
    xml.tag! 'PRE-RES'
    xml.NOTE
    xml.tag! 'PTN-TYPE'
    xml.CONTRI @question.answers.collect(&:user).collect(&:login).uniq.join(' ')
  }
}

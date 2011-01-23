class ResourceSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Expression, Work, Reify, Embody, Exemplify,
    Create, Realize, Produce, Own, Patron, Language,
    WorkRelationship, ExpressionRelationship,
    ManifestationRelationship, ItemRelationship, PatronRelationship,
    SeriesStatement, SubjectHeadingType, Answer

  def after_save(record)
    case
    when record.is_a?(Patron)
      expire_editable_fragment(record)
      record.works.each do |work|
        expire_editable_fragment(work)
      end
      record.expressions.each do |expression|
        expire_editable_fragment(expression)
      end
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
      record.donated_items.each do |item|
        expire_editable_fragment(item)
      end
      record.patrons.each do |patron|
        expire_editable_fragment(patron)
      end
    when record.is_a?(Work)
      expire_editable_fragment(record)
      record.expressions.each do |expression|
        expire_editable_fragment(expression)
        expression.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
      record.patrons.each do |patron|
        expire_editable_fragment(patron)
      end
    when record.is_a?(Expression)
      expire_editable_fragment(record)
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
      record.patrons.each do |patron|
        expire_editable_fragment(patron)
      end
    when record.is_a?(Create)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.work)
      record.work.expressions.each do |expression|
        expire_editable_fragment(expression)
        expression.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
    when record.is_a?(Realize)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.expression)
      record.expression.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
        manifestation.expressions.each do |expression|
          expire_editable_fragment(expression)
        end
      end
    when record.is_a?(Produce)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.manifestation)
      record.manifestation.expressions.each do |expression|
        expire_editable_fragment(expression)
        expression.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
    when record.is_a?(Own)
      expire_editable_fragment(record.patron)
      expire_editable_fragment(record.item)
      expire_editable_fragment(record.item.manifestation)
    when record.is_a?(Reify)
      expire_editable_fragment(record.work)
      expire_editable_fragment(record.expression)
      record.expression.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
    when record.is_a?(Embody)
      expire_editable_fragment(record.expression)
      expire_editable_fragment(record.manifestation)
      record.manifestation.expressions.each do |expression|
        expire_editable_fragment(expression)
      end
      record.expression.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
    when record.is_a?(Exemplify)
      expire_editable_fragment(record.manifestation)
      expire_editable_fragment(record.item)
    when record.is_a?(WorkRelationship)
      expire_editable_fragment(record.parent)
      record.parent.expressions.each do |expression|
        expire_editable_fragment(expression)
        expression.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
      expire_editable_fragment(record.child)
      record.child.expressions.each do |expression|
        expire_editable_fragment(expression)
        expression.manifestations.each do |manifestation|
          expire_editable_fragment(manifestation)
        end
      end
    when record.is_a?(ExpressionRelationship)
      expire_editable_fragment(record.parent)
      expire_editable_fragment(record.parent.work)
      record.parent.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
      expire_editable_fragment(record.child)
      expire_editable_fragment(record.child.work)
      record.child.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation)
      end
    when record.is_a?(ManifestationRelationship)
      expire_editable_fragment(record.parent)
      record.parent.expressions.each do |expression|
        expire_editable_fragment(expression)
        expire_editable_fragment(expression.work)
      end
      expire_editable_fragment(record.child)
      record.child.expressions.each do |expression|
        expire_editable_fragment(expression)
        expire_editable_fragment(expression.work)
      end
    when record.is_a?(ItemRelationship)
      expire_editable_fragment(record.parent)
      expire_editable_fragment(record.parent.manifestation) if record.parent.manifestation
      expire_editable_fragment(record.child)
      expire_editable_fragment(record.child.manifestation) if record.child.manifestation
    when record.is_a?(PatronRelationship)
      expire_editable_fragment(record.parent)
      expire_editable_fragment(record.child)
    when record.is_a?(SeriesStatement)
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation, ['detail'])
      end
    when record.is_a?(SubjectHeadingTypeHasSubject)
      expire_editable_fragment(record.subject)
    when record.is_a?(Answer)
      record.items.each do |item|
        expire_editable_fragment(item.manifestation, ['detail'])
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end
end

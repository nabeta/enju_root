class Ability
  include CanCan::Ability

  def initialize(user, ip_address = nil)
    case user.try(:role).try(:name)
    when 'Administrator'
      can [:read, :create, :update], ClassificationType
      can :destroy, ClassificationType do |classification_type|
        classification_type.classifications.empty?
      end
      can [:read, :create, :update], Item
      can :destroy, Item
      can [:read, :create, :update], Library
      can :destroy, Library do |library|
        library.shelves.empty?
      end
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty?
      end
      can [:read, :create, :update], Patron
      can :destroy, Patron
      can [:read, :create, :update], Shelf
      can :destroy, Shelf do |shelf|
        shelf.items.empty?
      end
      can [:read, :create, :update], User
      can :destroy, User do |u|
        u != user
      end
      can [:read, :create, :update], UserGroup
      can :destroy, UserGroup do |user_group|
        user_group.users.empty?
      end
      can :manage, [
        Classification,
        Create,
        CreateType,
        Donate,
        Event,
        EventCategory,
        Exemplify,
        ExpressionRelationship,
        Expression,
        EventImportFile,
        ImportRequest,
        InterLibraryLoan,
        ItemHasUseRestriction,
        ManifestationRelationship,
        ManifestationRelationshipType,
        Message,
        NewsFeed,
        NewsPost,
        Own,
        Participate,
        PatronImportFile,
        PatronMerge,
        PatronMergeList,
        PatronRelationship,
        PatronRelationshipType,
        PictureFile,
        Produce,
        ProduceType,
        Realize,
        RealizeType,
        ResourceImportFile,
        SearchEngine,
        SearchHistory,
        SeriesStatement,
        Subject,
        SubjectHasClassification,
        SubjectHeadingType,
        SubjectHeadingTypeHasSubject,
        SubjectType,
        Subscribe,
        Subscription,
        Tag,
        UserHasRole,
        Work,
        WorkHasSubject,
        WorkRelationship,
        WorkToExpressionRelType
      ]
      can [:read, :update], [
        CarrierType,
        CirculationStatus,
        ContentType,
        Country,
        ExpressionRelationshipType,
        Extent,
        Frequency,
        FormOfWork,
        ItemRelationshipType,
        Language,
        LibraryGroup,
        License,
        MediumOfPerformance,
        MessageRequest,
        MessageTemplate,
        NiiType,
        PatronType,
        RequestStatusType,
        RequestType,
        Role,
        UseRestriction,
        WorkRelationshipType
      ]
      can :read, [
        EventImportResult,
        PatronImportResult,
        ResourceImportResult
      ]
    when 'Librarian'
      can [:index, :create], Bookmark
      can [:update, :destroy, :show], Bookmark do |bookmark|
        bookmark.user == user
      end
      can [:index, :create], Expression
      can [:show, :update, :destroy], Expression do |expression|
        expression.required_role_id <= 3
      end
      can [:read, :create, :update], Item
      can :destroy, Item
      can [:read, :create, :update], Manifestation
      can :destroy, Manifestation do |manifestation|
        manifestation.items.empty?
      end
      can [:index, :create], Message
      can [:update], Message do |message|
        message.sender == user
      end
      can [:show, :destroy], Message do |message|
        message.receiver == user
      end
      can [:read, :update, :destroy], MessageRequest
      can [:read, :update], MessageTemplate
      can [:index, :create], Patron
      can :show, Patron do |patron|
        patron.required_role_id <= 3
      end
      can [:index, :create], Patron
      can :show, Patron do |patron|
        patron.required_role_id <= 3 #'Librarian'
      end
      can [:update, :destroy], Patron do |patron|
        patron.required_role_id <= 3 #'Librarian'
        patron.user.role.name != 'Administrator' if patron.user
      end
      can :index, SearchHistory
      can [:show, :destroy], SearchHistory do |search_history|
        search_history.user == user
      end
      can [:read, :create, :update], User
      can :destroy, User do |u|
        u != user
      end
      can [:index, :create], Work
      can [:show, :update, :destroy], Work do |work|
        work.required_role_id <= 3
      end
      can :manage, [
        Bookmark,
        BookmarkStat,
        BookmarkStatHasManifestation,
        Create,
        Donate,
        Embody,
        Event,
        Exemplify,
        ExpressionMerge,
        ExpressionMergeList,
        ExpressionRelationship,
        EventImportFile,
        ImportRequest,
        InterLibraryLoan,
        ItemHasUseRestriction,
        ItemRelationship,
        ManifestationRelationship,
        NewsPost,
        Own,
        Participate,
        PatronImportFile,
        PatronMerge,
        PatronMergeList,
        PatronRelationship,
        PictureFile,
        Produce,
        Realize,
        Reify,
        ResourceImportFile,
        SearchHistory,
        SeriesStatement,
        SubjectHasClassification,
        Subscribe,
        Subscription,
        Tag,
        WorkHasSubject,
        WorkMerge,
        WorkMergeList,
        WorkRelationship
      ]
      can :read, [
        CarrierType,
        CirculationStatus,
        Classification,
        ClassificationType,
        ContentType,
        Country,
        EventCategory,
        EventImportResult,
        ExpressionRelationshipType,
        Extent,
        Frequency,
        FormOfWork,
        ItemRelationshipType,
        Language,
        Library,
        LibraryGroup,
        License,
        ManifestationRelationshipType,
        MediumOfPerformance,
        MessageTemplate,
        NewsFeed,
        NiiType,
        PatronImportResult,
        PatronRelationshipType,
        PatronType,
        RequestStatusType,
        RequestType,
        ResourceImportResult,
        Role,
        SearchEngine,
        Shelf,
        Subject,
        SubjectType,
        SubjectHeadingType,
        UseRestriction,
        UserGroup,
        WorkRelationshipType,
        WorkToExpressionRelType
      ]
    when 'User'
      can [:index, :create], Bookmark
      can [:show, :update, :destroy], Bookmark do |bookmark|
        bookmark.user == user
      end
      can :index, Expression
      can :show, Expression do |expression|
        expression.required_role_id <= 2
      end
      can :index, Item
      can :show, Item do |item|
        item.required_role_id <= 2
      end
      can :read, Manifestation do |manifestation|
        manifestation.required_role_id <= 2
      end
      can :edit, Manifestation
      can [:read, :destroy], Message do |message|
        message.receiver == user
      end
      can :index, Message
      can :show, Message do |message|
        message.receiver == user
      end
      can [:index, :create], Patron
      can :update, Patron do |patron|
        patron.user == user
      end
      can :show, Patron do |patron|
        if patron.user == user
          true
        elsif patron.user != user
          true if patron.required_role_id <= 2 #name == 'Administrator'
        end
      end
      can :index, PictureFile
      can :show, PictureFile do |picture_file|
        begin
          true if picture_file.picture_attachable.required_role_id <= 2
        rescue NoMethodError
          true
        end
      end
      can :index, SearchHistory
      can [:show, :destroy], SearchHistory do |search_history|
        search_history.user == user
      end
      can :show, User
      can :update, User do |u|
        u == user
      end
      can :index, Work
      can :show, Work do |work|
        work.required_role_id <= 2
      end
      can :read, [
        CarrierType,
        CirculationStatus,
        Classification,
        ClassificationType,
        ContentType,
        Country,
        Create,
        Embody,
        Event,
        EventCategory,
        Exemplify,
        ExpressionRelationship,
        ExpressionRelationshipType,
        Extent,
        Frequency,
        FormOfWork,
        ItemRelationship,
        ItemRelationshipType,
        Language,
        Library,
        LibraryGroup,
        License,
        ManifestationRelationship,
        ManifestationRelationshipType,
        MediumOfPerformance,
        NewsFeed,
        NewsPost,
        NiiType,
        Own,
        PatronRelationship,
        PatronRelationshipType,
        Produce,
        Realize,
        Reify,
        SeriesStatement,
        Shelf,
        Subject,
        SubjectHasClassification,
        SubjectHeadingType,
        SubjectHeadingTypeHasSubject,
        Tag,
        UserGroup,
        WorkHasSubject,
        WorkRelationship,
        WorkRelationshipType,
        WorkToExpressionRelType
      ]
    else
      can :index, Expression
      can :read, Expression do |expression|
        expression.required_role_id == 1
      end
      can :index, Patron
      can :show, Patron do |patron|
        patron.required_role_id == 1 #name == 'Guest'
      end
      can :index, Work
      can :read, Work do |work|
        work.required_role_id == 1
      end
      can :read, [
        CarrierType,
        CirculationStatus,
        Classification,
        ClassificationType,
        ContentType,
        Country,
        Create,
        Embody,
        Event,
        EventCategory,
        Exemplify,
        ExpressionRelationship,
        ExpressionRelationshipType,
        Extent,
        Frequency,
        FormOfWork,
        Item,
        ItemRelationship,
        ItemRelationshipType,
        Language,
        Library,
        LibraryGroup,
        License,
        Manifestation,
        ManifestationRelationship,
        ManifestationRelationshipType,
        MediumOfPerformance,
        NewsFeed,
        NewsPost,
        NiiType,
        Own,
        PatronRelationship,
        PatronRelationshipType,
        PictureFile,
        Produce,
        Reify,
        Realize,
        SeriesStatement,
        Shelf,
        Subject,
        SubjectHasClassification,
        SubjectHeadingType,
        SubjectHeadingTypeHasSubject,
        Tag,
        UserGroup,
        WorkHasSubject,
        WorkRelationship,
        WorkRelationshipType,
        WorkToExpressionRelType
      ]
    end
  end
end

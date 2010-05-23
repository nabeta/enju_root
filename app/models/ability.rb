class Ability
  include CanCan::Ability

  def initialize(user)
    case user.try(:highest_role).try(:name)
    when 'Administrator'
      can :manage, :all
    when 'Librarian'
      can :manage, [Work, Expression, Manifestation, Item]
      can :manage, [Create, Realize, Produce, Own]
      can :manage, [Embody, Exemplify, Reify]
      can :index, Patron
      can :show, Patron do |patron|
        patron.required_role_id <= 3 #'Librarian'
      end
      can [:create, :update, :destroy], Patron do |patron|
        patron.required_role_id <= 3 #'Librarian'
        patron.try(:user).try(:highest_role).try(:name) != 'Administrator'
      end
      can :manage, User
      can :read, [Advertisement, Bookstore, Donate]
      can :manage, [Basket, Checkout, Checkin]
      can :read, Subject
      can :manage, Bookmark
      can :manage, [Question, Answer]
      can :manage, [WorkMerge, WorkMergeList]
      can :manage, [ExpressionMerge, ExpressionMergeList]
      can :manage, [PatronMerge, PatronMergeList]
      can :read, [Classification, ClassificationType]
      can :read, [SubjectType, SubjectHeadingType]
      can :manage, SubjectHasClassification
      can :manage, [Subscribe, Subscription]
      can :manage, Reserve
      can :manage, PurchaseRequest
      can :manage, PictureFile
      can :manage, PatronHasPatron
      can :manage, Order
      can :manage, OrderList
      can :read, NewsFeed
      can :manage, NewsPost
      can :read, [Country, Language]
      can :read, CirculationStatus
      can :read, Library
      can :manage, Event
      can :read, EventCategory
      can :manage, InterLibraryLoan
      can :manage, [Inventory, InventoryFile]
      can :read, [License, Extent, Frequency, FormOfWork]
      can :read, [
        WorkRelationshipType, ExpressionRelationshipType,
        ManifestationRelationshipType, ItemRelationshipType,
        PatronRelationshipType
      ]
      can :read, UserGroup
      can :manage, BookmarkStat
      can :manage, [UserCheckoutStat, UserReserveStat]
      can :manage, [ManifestationCheckoutStat, ManifestationReserveStat]
      can :manage, [
        WorkHasWork, ExpressionHasExpression, ManifestationHasManifestation,
        ItemHasItem, PatronHasPatron
      ]
      can :manage, Tag
      can :read, SearchEngine
      can :read, SearchHistory
      can :read, Role
      can :manage, [ResourceImportFile, PatronImportFile, EventImportFile]
      can :read, PatronType
      can :read, MediumOfPerformance
      can :manage, Message
      can :manage, MessageRequest
      can :read, MessageTemplate
      can :read, LibraryGroup
      can :read, [UserGroup, UserGroupHasCheckoutType]
      can :manage, WorkHasSubject
      can :read, CarrierType
      can :read, CheckoutType
      can :read, CarrierTypeHasCheckoutType
      can :manage, CheckedItem
      can :manage, [CheckoutStatHasManifestation, CheckoutStatHasUser]
      can :manage, [ReserveStatHasManifestation, ReserveStatHasUser]
      can :read, [CirculationStatus, UseRestriction]
      can :manage, ImportedObject
      can :manage, UserHasShelf
      can :read, Shelf
      can :read, [RequestStatusType, RequestType]
      can :manage, PictureFile
      can :manage, Participate
      can :manage, MessageTemplate
      can :manage, ItemHasUseRestriction
      can :manage, Donate
      can :manage, BookmarkStatHasManifestation
      can :read, ContentType
      can :read, Advertise
      can :read, NiiType
      can :read, WorkToExpressionRelType
    when 'User'
      can :read, [Work, Expression, Manifestation, Item]
      can :edit, Manifestation
      can :read, [Create, Realize, Produce, Own]
      can :read, [Embody, Exemplify, Reify]
      can :index, Patron
      can :create, Patron
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
      can :show, User
      can :update, User do |u|
        u == user
      end
      can :create, Bookmark
      can [:update, :destroy, :show], Bookmark do |bookmark|
        bookmark && bookmark.user == user
      end
      can :read, Library
      can :read, Shelf
      can :read, Subject
      can :create, Tag
      can :read, Tag
      can :create, [Question, Answer]
      can [:update, :destroy], [Question, Answer] do |object|
        object.user == user
      end
      can :read, [Event, EventCategory]
      can :read, [Country, Language, License]
      can :read, UserGroup
      can :read, WorkHasSubject
      can :read, [WorkHasWork, ExpressionHasExpression]
      can :read, [ManifestationHasManifestation, ItemHasItem]
      can :read, PatronHasPatron
      can :read, [WorkRelationshipType, ExpressionRelationshipType]
      can :read, [ManifestationRelationshipType, ItemRelationshipType]
      can :read, PatronRelationshipType
      can :read, [SubjectHeadingType, SubjectHasClassification]
      can [:update, :destroy, :show], [
        Bookmark, Checkout, PurchaseRequest, Reserve, UserHasShelf
      ] do |object|
        object.try(:user) == user
      end
      can :index, Question
      can :show, [Question, Answer] do |object|
        object.user == user or object.shared
      end
      can [:index, :create], [
        Answer, Bookmark, Checkout, PurchaseRequest, Reserve, UserHasShelf
      ]
      can :read, PictureFile
      can :read, MediumOfPerformance
      can :read, LibraryGroup
      can :read, LendingPolicy
      can :read, [License, Extent, Frequency, FormOfWork]
      can :read, ContentType
      can :read, [CirculationStatus, Classification, ClassificationType]
      can :read, CarrierType
      can :read, BookmarkStat
      can :read, NiiType
      can :read, WorkToExpressionRelType
      can :manage, Message
    else
      can :index, [Work, Expression]
      can :show, [Work, Expression] do |object|
        object.required_role_id == 1
      end
      can :read, Manifestation
      can :read, Item
      can :index, Patron
      can :show, Patron do |patron|
        patron.required_role_id == 1 #name == 'Guest'
      end
      can :read, [Create, Realize, Produce, Own]
      can :read, [Embody, Exemplify, Reify]
      can :read, [WorkHasWork, ExpressionHasExpression]
      can :read, [ManifestationHasManifestation, ItemHasItem]
      can :read, PatronHasPatron
      can :read, Country
      can :read, Event
      can :read, EventCategory
      can :read, Language
      can :read, Library
      can :read, Shelf
      can :read, Subject
      can :read, Tag
      can :index, Question
      can :show, [Question, Answer] do |object|
        object.user == user or object.shared
      end
      can :read, [ManifestationCheckoutStat, ManifestationReserveStat]
      can :read, [UserCheckoutStat, UserReserveStat]
      can :read, WorkRelationshipType
      can :read, ExpressionRelationshipType
      can :read, ManifestationRelationshipType
      can :read, ItemRelationshipType
      can :read, PatronRelationshipType
      can :read, [SubjectHeadingType, SubjectHasClassification]
      can :read, UserGroup
      can :read, WorkHasSubject
      can :read, WorkHasWork
      can :read, WorkToExpressionRelType
      can :read, PictureFile
      can :read, NiiType
      can :read, [NewsFeed, NewsPost]
      can :read, MediumOfPerformance
      can :read, LibraryGroup
      can :read, LendingPolicy
      can :read, [License, Extent, Frequency, FormOfWork]
      can :read, ContentType
      can :read, [CirculationStatus, Classification, ClassificationType]
      can :read, CarrierType
      can :read, BookmarkStat
      can :read, Resource
      can :read, SubjectHeadingTypeHasSubject
      can :index, Checkout
    end
  end
end

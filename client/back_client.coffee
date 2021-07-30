@picked_tags = new ReactiveArray []



$.cloudinary.config
    cloud_name:"facet"

        
Template.body.events
    'click .zoom_in_card': (e,t)->
        $(e.currentTarget).closest('.column').transition('drop', 1000)
    'click .zoom_out': (e,t)->
        $(e.currentTarget).closest('.grid').transition('scale', 1000)
    'click .fly_up': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly up', 1000)
    'click .cards_up': (e,t)->
        $(e.currentTarget).closest('.cards').transition('fly up', 1000)
    'click .fly_down': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly down', 1000)
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 1000)
    'click .fly_left': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly left', 1000)


    "click a:not('.no_blink')": ->
        $('.global_container')
        .transition('fade out', 200)
        .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1


Template.home.helpers
    logging_in: -> Meteor.loggingIn()
    
    
# Template.home_item.onRendered ->
#     Meteor.call 'log_view', @data._id

        


Template.home_item.events
    'click .clear_current_post': ->
        Session.set('viewing_post_id',null)
        picked_tags.pop()
            
    
    'click .delete_post':->
        if confirm 'delete?'
            Docs.remove @_id
            Session.set('viewing_post_id',null)
    'click .save_post': -> Session.get('viewing_post_id', @_id)

Template.tag_picker.onCreated ->
    @autorun => @subscribe 'ref_doc', @data, ->
Template.unpick_tag.onCreated ->
    @autorun => @subscribe 'flat_ref_doc', @data, ->
Template.flat_tag_picker.onCreated ->
    @autorun => @subscribe 'flat_ref_doc', @data, ->
Template.home.onCreated ->
    @autorun => @subscribe('doc_by_id',Session.get('viewing_post_id'))
    @autorun => @subscribe 'post_docs',
        picked_tags.array()
        Session.get('title_filter')

    @autorun => @subscribe 'post_facets',
        picked_tags.array()
        Session.get('title_filter')

Template.tag_picker.events
    'click .pick_tag': -> 
        picked_tags.push @title
        Session.set('viewing_post_id',null)
        # Meteor.call 'call_wiki', @title,=>
        #     console.log 'called wiki on', @title

Template.home.helpers
    one_doc: ->
        count = 
            Docs.find(
                model:'post'
                app:'bc'
                tags:$in:picked_tags.array()
            ).count()
        # console.log 'count', count
        count is 1
        
Template.home_item.helpers
    one_doc: ->
        count = 
            Docs.find(
                model:'post'
                app:'bc'
                tags:$in:picked_tags.array()
            ).count()
        # console.log 'count', count
        count is 1
    two_doc: ->
        count = 
            Docs.find(
                model:'post'
                app:'bc'
                tags:$in:picked_tags.array()
            ).count()
        # console.log 'count', count
        count is 2
        
        
Template.flat_tag_picker.events
    'click .flat_tag_pick': ->
        # console.log @
        picked_tags.clear()
        picked_tags.push @valueOf()
        Session.set('viewing_post_id',null)
Template.flat_tag_picker.helpers
    ref_doc_flat: ->
        # console.log @valueOf()
        found = Docs.findOne 
            model:'post'
            title:@valueOf()
        if found 
            found
        else 
            Docs.findOne
                model:'post'
                tags:$in:[@valueOf()]
                app:'bc'

Template.tag_picker.helpers
    ref_doc: ->
        # console.log @valueOf()
        found = 
            Docs.findOne 
                model:'post'
                title:@title
        if found 
            found
        else 
            Docs.findOne
                model:'post'
                tags:$in:[@title]
                app:'bc'

Template.home.helpers        
    picked_tags: -> picked_tags.array()

    # post_docs: ->
    #     Docs.find 
    #         model:'post'
    tag_results: ->
        doc_count = Docs.find({
            model:'post'
            tags:$all:picked_tags.array()
            }).count()
        # console.log 'count', doc_count
        if doc_count > 0
            Results.find {
                count:$lt:doc_count
                model:'post_tag'
            }, sort:_timestamp:-1
        else
            Results.find {
                model:'post_tag'
            }, sort:_timestamp:-1

    ref_doc_flat: ->
        found = 
            Docs.findOne 
                model:'post'
                app:'bc'
                title:@valueOf()
        if found 
            found
        else 
            Docs.findOne
                model:'post'
                tags:$in:[@valueOf()]
                app:'bc'

    current_post: ->
        Docs.findOne
            _id:Session.get('viewing_post_id')
            
    home_items: ->
        match = {
            model:'post'
            app:'bc'
        }
        # if picked_tags?.array().length > 0
        match.tags = $in:picked_tags.array()
        Docs.find match,
            sort:views:-1
       
Template.unpick_tag.helpers
    ref_doc_flat: ->
        # console.log @
        
        match = {}
        match.app = 'bc'
        match.model = 'post'
        match.title = @valueOf()
        found = 
            Docs.findOne match
        if found
            found 
        else 
            # console.log found
            match.title = null
            match.tags = $in: [@valueOf()]
            Docs.findOne match
            

       
            
Template.home_item.helpers
    card_class: ->
        if Session.equals('viewing_post_id', @_id) then 'inverted large' else 'small basic' 
    is_selected: -> Session.equals('viewing_post_id', @_id)
Template.home_item.events
    'click .edit_this': ->
        Session.set('is_editing',@_id)
    'click .save_this': ->
        Session.set('is_editing',false)
Template.home_item.helpers
    is_editing: -> Session.equals('is_editing',@_id)
# Template.home_item.helpers
#     is_editing: -> Session.get('is_editing')
Template.home_item.events
    'click .view_item': ->
        Session.set('viewing_post_id', @_id)
        Docs.update @_id, 
            $inc:views:1
Template.home.events
    'click .add_post': ->
        new_id = Docs.insert 
            model:'post'
            tags:picked_tags.array()
            title:picked_tags.array().toString()
        Session.set('viewing_post_id', new_id)    
        Session.set('is_editing', @_id)    
    'click .unpick_tag': -> 
        Session.set('viewing_post_id', null)
        picked_tags.remove @valueOf()

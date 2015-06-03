require 'spec_helper'

module ZendeskRails
  feature 'Tickets' do
    background { configure test_mode: true }

    feature 'new' do
      shared_examples 'new ticket validation' do
        scenario 'User creates a new ticket w/ blank subject' do
          fill_in 'ticket[body]', with: 'Example body'
          click_button 'Send Your Question'
          expect(page).to have_content("Subject can't be blank")
        end

        scenario 'User creates a new ticket w/ blank body' do
          fill_in 'ticket[subject]', with: 'Example subject'
          click_button 'Send Your Question'
          expect(page).to have_content("Body can't be blank")
        end
      end

      context 'authenticated' do
        background { visit new_ticket_path }

        scenario 'User creates a new ticket' do
          fill_in 'ticket[subject]', with: 'Example subject'
          fill_in 'ticket[body]', with: 'Example body'
          click_button 'Send Your Question'
          expect(page).to have_content('Thank you for your submission!')
        end

        include_examples 'new ticket validation'
      end

      context 'unauthenticated' do
        background { sign_out }
        background { visit new_ticket_path }

        scenario 'User creates a new ticket' do
          fill_in 'ticket[name]', with: 'User name'
          fill_in 'ticket[email]', with: 'user@example.com'
          fill_in 'ticket[subject]', with: 'Example subject'
          fill_in 'ticket[body]', with: 'Example body'
          click_button 'Send Your Question'
          expect(page).to have_content('Thank you for your submission!')
        end

        include_examples 'new ticket validation'
      end
    end

    context 'with existing ticket' do
      given!(:ticket) do
        Ticket.new(
          subject: 'Example Subject',
          body: 'Example body',
          requester: {
            email: 'user@example.com',
            name: 'User Example'
          }
        ).create
      end

      feature 'show' do
        scenario 'User views ticket' do
          visit ticket_path(ticket.id)
          expect(page).to have_content(ticket.id)
          expect(page).to have_content(ticket.subject)
        end

        scenario 'User views comments for ticket' do
          Comment.new(ticket, comment: 'Test Comment').save
          visit ticket_path(ticket.id)
          expect(page).to have_content('Test Comment')
        end

        scenario 'User views ticket that doesn\'t exist' do
          Testing::Ticket.clear!
          visit ticket_path(ticket.id)
          expect(page).to have_content('We were unable to locate the requested ticket')
        end
      end

      feature 'list' do
        scenario 'User views ticket list' do
          visit tickets_path
          expect(page).to have_content(ticket.id)
          expect(page).to have_content(ticket.status.titleize)
          expect(page).to have_content(ticket.subject)
        end
      end

      feature 'comment' do
        scenario 'User comments on ticket' do
          visit ticket_path(ticket.id)
          fill_in 'ticket[comment]', with: 'Example comment'
          click_button 'Add Comment'
          expect(page).to have_content('Comment successfully submitted.')
        end

        scenario 'User comments on ticket w/ blank comment' do
          visit ticket_path(ticket.id)
          click_button 'Add Comment'
          expect(page).to have_content("Comment can't be blank")
        end
      end
    end
  end
end

from django.core.management.base import BaseCommand
from api.services.ai_agent_service import AIAgentService
import logging

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    help = 'Initialize Neo4j knowledge base with vector indexes'

    def handle(self, *args, **options):
        self.stdout.write('Initializing Neo4j knowledge base...')
        
        try:
            ai_agent = AIAgentService()
            success = ai_agent.initialize_knowledge_base()
            
            if success:
                self.stdout.write(
                    self.style.SUCCESS('Successfully initialized Neo4j knowledge base!')
                )
            else:
                self.stdout.write(
                    self.style.WARNING('Knowledge base initialization completed with warnings')
                )
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Error initializing knowledge base: {e}')
            )
            logger.error(f"Error initializing knowledge base: {e}")


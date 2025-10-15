"""add default_currency to users

Revision ID: 872194d3a716
Revises: c29ae870b91e
Create Date: 2025-10-15 19:15:15.813262

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '872194d3a716'
down_revision: Union[str, Sequence[str], None] = 'c29ae870b91e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('users', sa.Column('default_currency', sa.String(), nullable=False, server_default='USD'))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('users', 'default_currency')

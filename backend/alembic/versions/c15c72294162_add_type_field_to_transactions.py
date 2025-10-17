"""Add type field to transactions

Revision ID: c15c72294162
Revises: 872194d3a716
Create Date: 2025-10-17 15:33:18.323205

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c15c72294162'
down_revision: Union[str, Sequence[str], None] = '872194d3a716'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    transaction_type = sa.Enum('income', 'expense', name='transactiontype')
    transaction_type.create(op.get_bind(), checkfirst=True)

    op.add_column(
        'transactions',
        sa.Column('type', transaction_type, nullable=False, server_default='expense')
    )


def downgrade() -> None:
    op.drop_column('transactions', 'type')
    sa.Enum(name='transactiontype').drop(op.get_bind(), checkfirst=True)

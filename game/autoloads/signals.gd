extends Node


# Señales comunes o más importates

# Final de una etapa (se define cuando pierde o gana) pero no necesariamente
# termina el ejercicio.
signal stage_ended()

# Deprecados (Usar los con el nombre correcto)
# Termina un ejercicio
#signal exercise_win(points, total_time)
# Pierde la partida (El ejercicio)
#signal exercise_lost(points, total_time)
# Pasa al apróximo ejercicio
#signal exercise_next()

# Termina un ejercicio
signal exercise_win(points, total_time)
# Pierde la partida (El ejercicio)
signal exercise_lost(points, total_time)
# Pasa al apróximo ejercicio
signal exercise_next()

signal interactable_element_clicked()
signal interactable_element_awaiting()

@Component(
	selector: 'my-selector',
	templateUrl: 'my_selector.html',
	template: '''
		<div (click)="handleClick(\$event)">
		</div>
	''',
	other_template: '''
		<div class="error" [ngStyle]="style">
		<div *ngIf="visible" class="error">
			<div class="error-type">{{errorType}}</div>
			<div *ngFor="let errorDetail of errorDetails; let i = index">
			<div>{{errorDetail}}</div>
			</div>
		</div>
		</div>
	''',
)
class mySelector {
	// nested string interpolation
	String _selectorName(HangingProtocolContainer hpc) => '${getLocalizedContent('StudySelector', prefix: 'Settings')} ${getLocalizedContent('is', prefix: 'Config.HP.Rule.Operator')} ${(hpc.selector.hidden ? '${hpc.selector.name} (${getLocalizedContent('Settings.Selector.deprecated')})' : hpc.selector.name)}';
}